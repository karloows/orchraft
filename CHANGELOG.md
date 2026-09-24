# Changelog

## [1.2.0](https://github.com/karloows/orchraft/compare/v1.1.0...v1.2.0) (2026-09-24)


### Features

* add Cursor plugin manifest and marketplace ([#70](https://github.com/karloows/orchraft/issues/70)) ([0b7a19e](https://github.com/karloows/orchraft/commit/0b7a19efc625061c38c9aafe668cffa4f12b4c11))

## [1.1.0](https://github.com/karloows/orchraft/compare/v1.0.3...v1.1.0) (2026-09-23)


### Features

* add muster status skill ([#64](https://github.com/karloows/orchraft/issues/64)) ([6fd678c](https://github.com/karloows/orchraft/commit/6fd678ca2c44694df188bfbed11ce67ef9025b4d))
* add plunder status skill ([#63](https://github.com/karloows/orchraft/issues/63)) ([570f4bb](https://github.com/karloows/orchraft/commit/570f4bba8e65182429c19ed5a24912555cc9e83a))
* add root plugin.json per the real Agent Plugins 1.0.0 standard ([#62](https://github.com/karloows/orchraft/issues/62)) ([9873c60](https://github.com/karloows/orchraft/commit/9873c60786d0821a8a4faffb886cd1a9748288fb))
* **evals:** add quest and herald approval-gate cases ([#59](https://github.com/karloows/orchraft/issues/59)) ([b81a642](https://github.com/karloows/orchraft/commit/b81a64201631b83c786c666f255a2caf3472e1fa))


### Bug Fixes

* **codex:** bump the self-hosted marketplace's stale commit pin ([#57](https://github.com/karloows/orchraft/issues/57)) ([bd5ccab](https://github.com/karloows/orchraft/commit/bd5ccabc68839c99eefe529dc563b7719d158283))
* **evals:** cover all gh issue/release mutation paths in the graders ([#60](https://github.com/karloows/orchraft/issues/60)) ([63c89ba](https://github.com/karloows/orchraft/commit/63c89ba5ff22ebd3265263e14040241816eb4442))

## [1.0.3](https://github.com/karloows/orchraft/compare/v1.0.2...v1.0.3) (2026-09-21)


### Bug Fixes

* move skill content to skills/, drop per-ecosystem symlinks ([a83ceec](https://github.com/karloows/orchraft/commit/a83ceec7a233cf6706724cc47596ed98a7d9ed79))
* **roast:** drop the standing-preference trigger for posting a review ([534d9a8](https://github.com/karloows/orchraft/commit/534d9a884f699e16178e2cffcbbbc32a89fa1878))
* **skills:** move skill content to skills/, drop per-ecosystem symlinks ([5699d09](https://github.com/karloows/orchraft/commit/5699d099904d3383aefd7c788c1b1a7d1d2696a0))
* **templates:** let the checklist accept a policy-only change ([aefb9ac](https://github.com/karloows/orchraft/commit/aefb9ace8b6e247696b1a62ea019f4d0b769f560))

## [1.0.2](https://github.com/karloows/orchraft/compare/v1.0.1...v1.0.2) (2026-09-21)


### Bug Fixes

* **release:** sync the Codex manifest into release-please's extra-files ([5ac6322](https://github.com/karloows/orchraft/commit/5ac63229d0acbe01350edc8d0be33fc2f4d0f3e7))
* sync the Codex manifest and rewrite the plugin description ([ebefe88](https://github.com/karloows/orchraft/commit/ebefe88425df669ceff22c5de0f2c58625fd021a))

## [1.0.1](https://github.com/karloows/orchraft/compare/v1.0.0...v1.0.1) (2026-09-21)


### Bug Fixes

* **hooks:** check the printed result, not just the exit status ([3b923ca](https://github.com/karloows/orchraft/commit/3b923ca2a3a6519b24bd63cfef04506c462c1107))
* **hooks:** gate before reading the command ([16e4d65](https://github.com/karloows/orchraft/commit/16e4d653a79746c4a483f27071f186af702a5c2b))
* **hooks:** gate on being inside a git repo before reading the command ([cf2fb33](https://github.com/karloows/orchraft/commit/cf2fb3305cb29572afadb1cddb7156416401a719))

## 1.0.0 (2026-09-21)


### Features

* add an optional per-repo config file ([bf732c9](https://github.com/karloows/orchraft/commit/bf732c9911ef41d41257a79bbdc4942be6814cc0))
* add an optional per-repo config file ([85846b4](https://github.com/karloows/orchraft/commit/85846b4355c6af70a297c0be2e48673e95c888cd))
* add chronicle, a standalone-documentation skill ([74a8de7](https://github.com/karloows/orchraft/commit/74a8de7f7e21865d5325d9002fd2a72a8ae697f7))
* add code comment and docstring skill ([19adc6a](https://github.com/karloows/orchraft/commit/19adc6a6c9cad9356e9848918cad0c72d98c89b7))
* add Codex CLI plugin manifests ([8540c5c](https://github.com/karloows/orchraft/commit/8540c5cbf0f3a3d13a58ad211f172cdfca696393))
* add herald skill for release notes ([c275998](https://github.com/karloows/orchraft/commit/c2759981415a5aa224224229cf58ed044990a84f))
* add issue triage/create/update skill ([#20](https://github.com/karloows/orchraft/issues/20)) ([1bfa9cd](https://github.com/karloows/orchraft/commit/1bfa9cdad61c818b8be606c203a84cc4297b03a9))
* add live status/resume skill ([#22](https://github.com/karloows/orchraft/issues/22)) ([6774e1b](https://github.com/karloows/orchraft/commit/6774e1b34f554875fc4beb471c0618f15c696218))
* add reckoning, a repo-wide declined-findings status skill ([6a09361](https://github.com/karloows/orchraft/commit/6a0936110ffb6ce92b55a028ba91bdbb340a9db9))
* add repo-grounded implementation planning skill ([#21](https://github.com/karloows/orchraft/issues/21)) ([0bf811a](https://github.com/karloows/orchraft/commit/0bf811a133f68efc7f43ce9841f5511b1ec9bea7))
* add review skill for PR review automation ([c092158](https://github.com/karloows/orchraft/commit/c092158a1e33989ad87363b75977eb4bd3e9b7c3))
* add self-hosted plugin marketplace listing ([94fa795](https://github.com/karloows/orchraft/commit/94fa7957ec8dce951b25fbbf6567831107c2a8e4))
* add watchtower SessionStart hook and autonomous-mode opt-in ([8adf826](https://github.com/karloows/orchraft/commit/8adf8265dcff0e12c67ebdef4930e52d27e5e29d))
* add watchtower status nudge skill ([b1bf312](https://github.com/karloows/orchraft/commit/b1bf3128a82ff0099bbbce4e80d2c55a62d871dd))
* add yap explainer skill ([b7cb507](https://github.com/karloows/orchraft/commit/b7cb5079a99e5828d5f43fcc852c1d4528499eff))
* **agents:** add watchtower status nudge skill ([dbaa43d](https://github.com/karloows/orchraft/commit/dbaa43dafe59925164c443e64bd3eea9b354fdac))
* **chronicle:** add standalone-documentation skill ([c7e9b63](https://github.com/karloows/orchraft/commit/c7e9b631a90ae19d12fa7a17cbb80a9df7154ab2))
* **codex:** add plugin manifests for Codex CLI installability ([e152eb9](https://github.com/karloows/orchraft/commit/e152eb97df1862511c8748942a04b26ff2371b1f))
* **grok:** add self-hosted plugin marketplace listing ([57b2bfc](https://github.com/karloows/orchraft/commit/57b2bfc0e557e3ca0545a033c3c2398bda69fdde))
* **herald:** add release notes skill ([b79c10e](https://github.com/karloows/orchraft/commit/b79c10ecee6535269e1561f1d973b856e1b1da57))
* **hooks:** nudge on direct-to-main git commit/push ([23e8b9f](https://github.com/karloows/orchraft/commit/23e8b9fdab933770cce75a884203828e196b6f2b))
* **lore:** add code comment and docstring skill ([92c4ce6](https://github.com/karloows/orchraft/commit/92c4ce63471115e63c48fe9e29ce7bd41899c83a))
* nudge on direct-to-main git commit/push ([870ed6d](https://github.com/karloows/orchraft/commit/870ed6d67d3cfbef19601a140c943250ee750530))
* package orchraft as a Claude Code plugin with orc voice ([386286b](https://github.com/karloows/orchraft/commit/386286b84f36531ed0296de4e386be844c9fa138))
* **plugin:** package orchraft as a Claude Code plugin ([0ab1fcc](https://github.com/karloows/orchraft/commit/0ab1fcc41a58e3cfbc2230db2617038cfd5ae60d))
* **reckoning:** add repo-wide declined-findings status skill ([43adda0](https://github.com/karloows/orchraft/commit/43adda0317427ad305ade40ec519b979a6a639b4))
* render roast findings as severity alerts with AI prompts ([22a98d1](https://github.com/karloows/orchraft/commit/22a98d1bdc1bceb2b37a2b3712a5c98a7b6ab956))
* reply with reasoning when declining a review finding ([76cd0d3](https://github.com/karloows/orchraft/commit/76cd0d3897e44d3ad3c2890af5470b3cb3f8ac92))
* **roast:** split large-diff file review across parallel subagents ([0fc618e](https://github.com/karloows/orchraft/commit/0fc618ebefa82599db09c646b5154f76b38c683c))
* **ship:** reply with reasoning when declining a review finding ([643133d](https://github.com/karloows/orchraft/commit/643133d8a412105cc504f53a6c5f1b022af5a802))
* **skills:** add AI agent prompts to roast findings ([0da7f78](https://github.com/karloows/orchraft/commit/0da7f78e4e964fd99fede5d4353ed631cedbe7e6))
* **skills:** add review skill for PR review automation ([458342e](https://github.com/karloows/orchraft/commit/458342e008ea0b7b61c14dd310da6d0dbb5bad5f))
* **skills:** add yap explainer skill ([69545c8](https://github.com/karloows/orchraft/commit/69545c83d557e053a674ba485d9dfe70d41bac80))
* **skills:** redesign roast review body with color and structure ([57c8a65](https://github.com/karloows/orchraft/commit/57c8a659eebf9cafbca3b9ead2f3c5db6165069f))
* **skills:** render roast inline comments as severity alerts ([34898c1](https://github.com/karloows/orchraft/commit/34898c1f5b1cc6054a0ab29ef206a55e0d042b20))
* split large-diff roast review across parallel subagents ([93c1317](https://github.com/karloows/orchraft/commit/93c1317362c73bfa9d7ac86c891c07cc578bd406))
* split warplan precedent search across parallel subagents ([ff86c14](https://github.com/karloows/orchraft/commit/ff86c1418b19e268d965249b3277b52813c554a4))
* **warplan:** split precedent search across parallel subagents ([195ae15](https://github.com/karloows/orchraft/commit/195ae15dd6ceb9f19699ea04723d3dee01c45485))
* **watchtower:** add SessionStart hook and autonomous-mode opt-in ([f8d8598](https://github.com/karloows/orchraft/commit/f8d8598071db4cbc3b36453b0a170bd00c7dc304))


### Bug Fixes

* accept only a boolean false, and name both config filenames ([131aa68](https://github.com/karloows/orchraft/commit/131aa68c22ea829d7bc631ad8eaab91dd7dffbdf))
* **chronicle:** narrow trigger to avoid overlap with yap ([8d7e60c](https://github.com/karloows/orchraft/commit/8d7e60c1c39061b7411f5209bbfc3ae0dad8f2eb))
* **chronicle:** scope the missing-rationale stop to whole-content gaps ([66ce721](https://github.com/karloows/orchraft/commit/66ce721dcf9d181bc062d0e8daf7a55002a6c2f0))
* **codex:** nest displayName under interface in plugin manifest ([166085f](https://github.com/karloows/orchraft/commit/166085f0a36297950687f7d011ad28ad284efab8))
* **codex:** pin marketplace plugin source to a reviewed commit SHA ([2028a5f](https://github.com/karloows/orchraft/commit/2028a5ff91eae49f8ac8936bbd9659c719b5e3cb))
* cut branches from the resolved base, not a literal main ([383a90b](https://github.com/karloows/orchraft/commit/383a90bfea6f292a64a0c5f4f9932f80fa135d4a))
* describe the nudge hook's resolved branch everywhere ([5083e57](https://github.com/karloows/orchraft/commit/5083e57af22f774a4fb9f8f24cdb89163207d310))
* follow the repository's own integration branch ([ca245cd](https://github.com/karloows/orchraft/commit/ca245cdda187b2c6fe6121a6c4b724448b71709c))
* **grok:** install by marketplace plugin name, not owner/repo ([3f26494](https://github.com/karloows/orchraft/commit/3f26494a73a4163b6fc97571f6c8dca857058167))
* **grok:** keep AGENTS.md generic, document real install command ([23e788e](https://github.com/karloows/orchraft/commit/23e788ede6e68e7ad8afffe4bbf253cd27f3d3c9))
* **herald:** cite a short SHA when a change has no pull request ([0255ddc](https://github.com/karloows/orchraft/commit/0255ddc37ffe92d93e93d4ea79dcdeb2333bfb3c))
* **herald:** cover direct commits in every summary of the sources ([c942253](https://github.com/karloows/orchraft/commit/c9422537a4ded73b054cc88c5f6f1c5c62cabfde))
* **herald:** keep re-publishing idempotent and the plain-text rule real ([74ca4d0](https://github.com/karloows/orchraft/commit/74ca4d05da7f3319e8929f6d35d30575d89dc6e0))
* **herald:** mark notes on every publish path ([b1dcff6](https://github.com/karloows/orchraft/commit/b1dcff6bda49aaa5880210583465ccedaa52a6a5))
* **herald:** resolve the range against fresh remote refs ([aa06525](https://github.com/karloows/orchraft/commit/aa065253b662fbd876aa56a6b089f99949280e76))
* **herald:** state the same approval rule in every place it appears ([33aba43](https://github.com/karloows/orchraft/commit/33aba431cdbfd7da97bf41eef7651477c63447b7))
* let the pull request decide its own base branch ([296f423](https://github.com/karloows/orchraft/commit/296f4238590afd3af763527c2d7b000188c5b06e))
* **lore:** address roast findings on the lore skill and its eval ([b258b79](https://github.com/karloows/orchraft/commit/b258b7906d86353eca357e71b9201bef976968e7))
* **policies:** scope ticket-key format and secrets prohibition correctly ([bb5b31f](https://github.com/karloows/orchraft/commit/bb5b31f2932cacc8713fbf673f38cdb76fa96fa8))
* **reckoning:** distinguish merged from closed-without-merging in gh fallback ([bda1c1f](https://github.com/karloows/orchraft/commit/bda1c1ff2d7e5659f9258a884c89f72784180b00))
* **reckoning:** handle truncated threads and missing line coordinates ([3d6a6a4](https://github.com/karloows/orchraft/commit/3d6a6a4aced50eb40d6d747b3faae7678e8e65ce))
* **reckoning:** name concrete search calls and the gh reply fallback ([1b1ad34](https://github.com/karloows/orchraft/commit/1b1ad34d396dd8d2297fa3df4c949261abd00699))
* **reckoning:** paginate PR/thread search and fix reply quoting ([a6e0407](https://github.com/karloows/orchraft/commit/a6e040700afc9e2ea7cdfccad036d0411be55537))
* **reckoning:** stop on partial search failure, report the decliner ([3c2b3e7](https://github.com/karloows/orchraft/commit/3c2b3e7b75bb6a37c5f111d06f6551d67fcda6ae))
* **reckoning:** use gh api --paginate instead of a fixed PR limit ([4fcc4cb](https://github.com/karloows/orchraft/commit/4fcc4cbe93336171481417759796a7036ec6731c))
* **release:** correct release-please action commit pin ([dd8a5bf](https://github.com/karloows/orchraft/commit/dd8a5bfba6eaa72debfa73f5800e63b9a80e18eb))
* **roast:** fix ungrammatical cross-file grouping sentence ([183c59d](https://github.com/karloows/orchraft/commit/183c59dbfcda8a8d515e4e41542d478b51c7d3fd))
* **roast:** merge overlapping cross-file groups before delegation ([0cd6d65](https://github.com/karloows/orchraft/commit/0cd6d65950613d4fc9675fa78df3f17bd2a324bb))
* **roast:** preserve cross-file checks in parallel subagent review ([5001934](https://github.com/karloows/orchraft/commit/500193410da9543f7dd8af97a93deba92f0dcd99))
* **roast:** scope integration sweep to flagged cross-file groups ([3384194](https://github.com/karloows/orchraft/commit/33841943df9dd39a231ce6e9f05b0ef46ab0d029))
* **roast:** skip integration sweep when no cross-file groups exist ([0f89ae9](https://github.com/karloows/orchraft/commit/0f89ae9796d694707bd0469305aac8cd09769bd5))
* **roast:** unify skip condition for cross-file integration pass ([bf86e8f](https://github.com/karloows/orchraft/commit/bf86e8f69f0447a19902fc878e0ec041fbc94870))
* **ship:** keep the default branch off-limits when baseBranch differs ([79f1cac](https://github.com/karloows/orchraft/commit/79f1cac3a1bd3b68df6bcadcb1c9c163a00910b3))
* **skills:** address review findings on PR review ownership and wording ([5c60261](https://github.com/karloows/orchraft/commit/5c60261a6e02c17a1cdb833e9dfe0cb0c015b175))
* **skills:** align ship commit bodies with commit policy ([a6bd55a](https://github.com/karloows/orchraft/commit/a6bd55ab31d66586643d99c7dfe0197034dc4e4e))
* **skills:** gate Copilot self-review request behind user approval ([f42a53a](https://github.com/karloows/orchraft/commit/f42a53a1c8574ea01de53645b03f7e104b353299))
* **skills:** honor plain output in handoffs and list personality file ([28b5a8b](https://github.com/karloows/orchraft/commit/28b5a8b8b867ee7711a048355ffdb552158c5276))
* **skills:** make yap portable and read-only in its references ([0d8707a](https://github.com/karloows/orchraft/commit/0d8707a71395e5f0034f20bd2e8881381dcc6769))
* **skills:** pin roast prompt placement and stale-line anchors ([7e0d33b](https://github.com/karloows/orchraft/commit/7e0d33b3bf60b907ac8476f4e554e81d963ef0ac))
* **skills:** shrink review-body headers, guard details nesting ([929d879](https://github.com/karloows/orchraft/commit/929d8791d873a106f2ddd8d90354cc379df39a77))
* **skills:** tighten review skill portability and safety wording ([f7c40c7](https://github.com/karloows/orchraft/commit/f7c40c7571ecb8bb81a74153ff88986df63ab063))
* **warchief:** let the approval policy answer what is authorized ([82206bb](https://github.com/karloows/orchraft/commit/82206bb9f9168b5e0f3497daaf54abd61e28dd98))
* **warplan:** allow read-only git/GitHub lookups in subagent search ([bde005c](https://github.com/karloows/orchraft/commit/bde005c1884030e20890dc1d47c58d48f054c4d7))
* **warplan:** finish mutation-wording fix in the Guardrails section ([61bba63](https://github.com/karloows/orchraft/commit/61bba6356293ed43962ec835a396e45702d43880))
* **watchtower:** address roast and CodeRabbit review findings ([7345013](https://github.com/karloows/orchraft/commit/734501366cd99e8ae9f4f523f42c4a4f884a6fc2))
* **watchtower:** catch in-progress checks and stale-ref trust gap ([756c597](https://github.com/karloows/orchraft/commit/756c597575e5d9310702a8c93dd02d70f75a362e))
* **watchtower:** reject null pullRequest in review-thread pagination ([9a8763b](https://github.com/karloows/orchraft/commit/9a8763b65f6071e80b466b40807072be0e5b8a62))
* wire the documented settings to real consumers ([e620fa6](https://github.com/karloows/orchraft/commit/e620fa63ce587c58042991857d8be3fefb2b46ef))
