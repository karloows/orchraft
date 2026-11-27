// OpenCode server plugin for orchraft. Ports hooks/hooks.json by shelling out
// to the same hooks/*.sh this repo ships for Claude Code (deterministic
// bash/git/gh state checks, not judgment calls) so the two hosts can't drift,
// and registers the bundled skills via ctx.skill.transform when available.
//
// Works in two layouts:
// - Package/plugin layout: scripts/opencode-plugin/orchraft-hooks.js with
//   hooks/ and skills/ at the repo/package root (../../hooks, ../../skills).
// - Copy-install layout: .opencode/plugins/orchraft-hooks.js with hook scripts
//   at .opencode/hooks/ (../hooks). scripts/install-opencode.sh also installs
//   skills to .opencode/skills/ (and .agents/skills/ for compatibility),
//   context to .opencode/context/, and agents to .opencode/agents/.
//
// Verified live against opencode 2.2.5: a default export of {id, setup} is
// accepted (the object-returning "export const Foo = async (...) => ({hooks})"
// style documented at opencode.ai/docs/plugins was rejected there with "Plugin
// must export a default definition with an id and an effect or setup
// function"); plugin code runs under Bun, so Bun.$ is available without an
// import; ctx.location.directory, ctx.event.subscribe,
// ctx.session.hook("context", ...), and ctx.tool.hook("execute.after", ...)
// all load and run without error. The main-branch commit/push nudge surfaces
// after the git command already ran, not before it like the Claude Code
// PreToolUse hook it ports -- see the comment on that hook.
//
// The built-in shell tool is registered as "shell", not "bash" (confirmed
// against packages/core/src/tool/plugin/shell.ts at the v2.2.5 tag). Its
// successful result is {output, content, metadata} where `output` is a
// structured object (exit/signal/truncated/...) and `content` is an array of
// {type, text} parts -- not plain strings -- except for a backgrounded command,
// whose result is {output: <string>, shellID, ...} with no `content`.
import { existsSync, readdirSync, readFileSync } from "node:fs"
import { homedir } from "node:os"
import { basename, dirname, join, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const here = dirname(fileURLToPath(import.meta.url))
const packageRoot = resolve(here, "../..")
const inCopyInstallLayout = basename(here) === "plugins" && basename(dirname(here)) === ".opencode"
const hooksDir = inCopyInstallLayout ? resolve(here, "../hooks") : join(packageRoot, "hooks")
const skillsDir = join(packageRoot, "skills")

// Mirrors FileAccess.resolvePath's tilde handling (packages/core/src/
// file-access.ts at the v2.2.5 tag), which the shell tool's own workdir
// resolution goes through -- a bare node:path resolve() leaves a leading
// "~" as a literal path segment instead of the home directory.
function resolveWorkdir(directory, workdir) {
  if (workdir === "~") return homedir()
  if (workdir.startsWith("~/") || (process.platform === "win32" && workdir.startsWith("~\\"))) {
    return resolve(homedir(), workdir.slice(2))
  }
  return resolve(directory, workdir)
}

function parseFrontmatter(text) {
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/)
  if (!match) return { data: {}, body: text }
  const data = {}
  for (const line of match[1].split(/\r?\n/)) {
    const m = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/)
    if (m) data[m[1]] = m[2].replace(/^['"]|['"]$/g, "")
  }
  return { data, body: match[2] }
}

function bundledSkills() {
  if (!existsSync(skillsDir)) return []
  return readdirSync(skillsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => {
      const file = join(skillsDir, entry.name, "SKILL.md")
      if (!existsSync(file)) return undefined
      const raw = readFileSync(file, "utf8")
      const { data, body } = parseFrontmatter(raw)
      return {
        id: entry.name,
        name: data.name || entry.name,
        description: data.description || "",
        path: file,
        content: body,
      }
    })
    .filter(Boolean)
}

async function registerSkills(ctx) {
  if (!ctx.skill?.transform) return
  const skills = bundledSkills()
  if (skills.length === 0) return
  try {
    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        if (editor.get?.(skill.id)) continue
        editor.add({
          id: skill.id,
          name: skill.name,
          description: skill.description,
          path: skill.path,
          content: skill.content,
        })
      }
    })
  } catch {
    // Skill registration is best-effort; file-based discovery still works.
  }
}

// Bun's $ ShellPromise has no .timeout()/AbortSignal of its own (checked
// against oven-sh/bun's packages/bun-types/shell.d.ts), unlike the 8s/5s
// Claude Code sets on these same scripts in hooks/hooks.json. Race it
// against a timer instead: a stalled script can't block the caller past
// timeoutMs, though the orphaned process itself (a read-only status check,
// never a mutation) keeps running until it exits on its own.
async function runHook(directory, script, stdin, timeoutMs) {
  try {
    const path = join(hooksDir, script)
    const json = JSON.stringify(stdin)
    const shell = Bun.$`printf '%s' ${json} | bash ${path}`.cwd(directory).quiet().nothrow().text()
    // Marks `shell` handled so a rejection arriving after the race below has
    // already timed out doesn't surface as an unhandled rejection.
    shell.catch(() => {})
    const timedOut = Symbol("timeout")
    const timer = new Promise((resolve) => setTimeout(() => resolve(timedOut), timeoutMs))
    const out = await Promise.race([shell, timer])
    if (out === timedOut) return undefined
    const text = JSON.parse(out || "{}")?.hookSpecificOutput?.additionalContext
    return typeof text === "string" && text ? text : undefined
  } catch {
    return undefined
  }
}

export default {
  id: "orchraft-hooks",
  async setup(ctx) {
    const directory = ctx.location?.directory ?? process.cwd()
    try {
      await registerSkills(ctx)
    } catch {
      // Skill registration is best-effort.
    }
    // Gates the watchtower check to once per session. Keyed on the
    // "context" hook, not a session.created subscription: session.created
    // never fires for a session resumed with `opencode --continue` after a
    // server restart, but "context" still runs on that session's next
    // model request, so this covers both a new and a resumed session.
    const checkedSessions = new Set()

    // Not awaited: this iterates for the plugin's lifetime, setup must
    // return so the rest of the server can start. Only cleans up
    // checkedSessions so it can't grow for the life of a long-running
    // server; it's not what triggers the watchtower check. Aborted via the
    // controller below on unload/reload, so a reloaded plugin doesn't stack
    // another subscription on top of a prior activation's still-running one.
    const sessionDeletedAbort = new AbortController()
    if (ctx.event?.subscribe) {
      void (async () => {
        try {
          for await (const event of ctx.event.subscribe({
            types: ["session.deleted"],
            signal: sessionDeletedAbort.signal,
          })) {
            const sessionID = event.data?.sessionID
            if (sessionID) checkedSessions.delete(sessionID)
          }
        } catch {
          // Subscription is best-effort; cleanup only bounds memory.
        }
      })()
    }

    if (ctx.session?.hook) {
      try {
        await ctx.session.hook("context", async (event) => {
          try {
            if (checkedSessions.has(event.sessionID)) return
            checkedSessions.add(event.sessionID)
            const text = await runHook(directory, "watchtower-nudge.sh", { cwd: directory }, 8_000)
            if (text) event.system.push({ type: "text", text })
          } catch {
            // Never block session context on a nudge failure.
          }
        })
      } catch {
        // Hook registration is best-effort.
      }
    }

    // Registered on execute.after, not execute.before: the Claude Code hook
    // this ports warns before the git command runs, but execute.before has
    // no result yet to append text to, and the model only ever sees a tool
    // result, not a pre-execution hook's return value. So unlike the
    // Claude Code hook, this nudge reaches the model only after the commit
    // or push to main has already happened -- an after-the-fact note, not
    // a chance to reconsider first.
    if (ctx.tool?.hook) {
      try {
        await ctx.tool.hook("execute.after", async (event) => {
          try {
            if (event.tool !== "shell" || event.status !== "completed") return
            const command = event.input?.command
            if (!command) return
            // The shell tool runs the command in its own call's `workdir` when
            // one is given, not necessarily this plugin's project directory; a
            // commit in another worktree needs the nudge to check that worktree's
            // branch, not this one's.
            const workdir =
              typeof event.input?.workdir === "string" && event.input.workdir
                ? resolveWorkdir(directory, event.input.workdir)
                : directory
            const text = await runHook(
              workdir,
              "main-commit-nudge.sh",
              { cwd: workdir, tool_input: { command } },
              5_000,
            )
            if (!text) return
            const result = event.result ?? {}
            if (Array.isArray(result.content)) {
              event.result = { ...result, content: [...result.content, { type: "text", text }] }
            } else if (typeof result.content === "string") {
              event.result = { ...result, content: `${result.content}\n\n${text}` }
            } else if (typeof result.output === "string") {
              event.result = { ...result, output: `${result.output}\n\n${text}` }
            }
          } catch {
            // Never interfere with shell tool results on a nudge failure.
          }
        })
      } catch {
        // Hook registration is best-effort.
      }
    }

    return () => sessionDeletedAbort.abort()
  },
}
