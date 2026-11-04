// opencode port of hooks/hooks.json. Shells out to the same hooks/*.sh this
// repo ships for Claude Code (deterministic bash/git/gh state checks, not
// judgment calls) instead of a second copy of that logic in JS, so the two
// hosts can't drift. install-opencode.sh installs this beside a copy of
// those scripts at .opencode/hooks/.
//
// Verified live against opencode 2.2.5: a default export of {id, setup} is
// the shape its loader accepts (the object-returning "export const Foo =
// async ({directory, ...}) => ({hooks})" style documented at
// opencode.ai/docs/plugins is rejected there with "Plugin must export a
// default definition with an id and an effect or setup function"); plugin
// code runs under Bun, so the global Bun.$ shell API is available without
// an import; ctx.location.directory, ctx.event.subscribe,
// ctx.session.hook("context", ...), and ctx.tool.hook("execute.after", ...)
// all load and run without error. The main-branch commit/push nudge below
// therefore surfaces after the git command already ran, not before it like
// the Claude Code PreToolUse hook it ports -- see the comment on that hook.
const hooksDir = new URL("../hooks/", import.meta.url)

async function runHook(directory, script, stdin) {
  try {
    const path = new URL(script, hooksDir).pathname
    const json = JSON.stringify(stdin)
    const out = await Bun.$`printf '%s' ${json} | bash ${path}`.cwd(directory).quiet().nothrow().text()
    const text = JSON.parse(out || "{}")?.hookSpecificOutput?.additionalContext
    return typeof text === "string" && text ? text : undefined
  } catch {
    return undefined
  }
}

export default {
  id: "orchraft-hooks",
  async setup(ctx) {
    const directory = ctx.location.directory
    const pendingBySession = new Map()

    // Not awaited: this iterates for the plugin's lifetime, setup must
    // return so the rest of the server can start.
    ;(async () => {
      for await (const event of ctx.event.subscribe({ types: ["session.created", "session.deleted"] })) {
        const sessionID = event.data?.sessionID
        if (!sessionID) continue
        if (event.type === "session.deleted") {
          // A session created and abandoned without ever prompting never
          // fires the "context" hook below, so without this its entry
          // would sit in pendingBySession for the server's lifetime.
          pendingBySession.delete(sessionID)
          continue
        }
        const text = await runHook(directory, "watchtower-nudge.sh", { cwd: directory })
        if (text) pendingBySession.set(sessionID, text)
      }
    })()

    await ctx.session.hook("context", async (event) => {
      const text = pendingBySession.get(event.sessionID)
      if (!text) return
      pendingBySession.delete(event.sessionID)
      event.system.push({ type: "text", text })
    })

    // Registered on execute.after, not execute.before: the Claude Code hook
    // this ports warns before the git command runs, but execute.before has
    // no result yet to append text to, and the model only ever sees a tool
    // result, not a pre-execution hook's return value. So unlike the
    // Claude Code hook, this nudge reaches the model only after the commit
    // or push to main has already happened -- an after-the-fact note, not
    // a chance to reconsider first.
    await ctx.tool.hook("execute.after", async (event) => {
      if (event.tool !== "bash" || event.status !== "completed") return
      const command = event.input?.command
      if (!command) return
      const text = await runHook(directory, "main-commit-nudge.sh", {
        cwd: directory,
        tool_input: { command },
      })
      if (!text) return
      // shortcut: appends only when the bash tool's result already carries a
      // plain-string output or content (true for opencode's built-in bash
      // tool); a tool that returns structured content array is left
      // untouched rather than guessing how to splice text into it. Upgrade
      // if a future bash tool variant stops setting a string output.
      const result = event.result ?? {}
      if (typeof result.output === "string") {
        event.result = { ...result, output: `${result.output}\n\n${text}` }
      } else if (typeof result.content === "string") {
        event.result = { ...result, content: `${result.content}\n\n${text}` }
      }
    })
  },
}
