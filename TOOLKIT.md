# King's Claude Toolkit

Every skill and plugin gathered so far, grouped by where each one loads.

Bookmarkable version: https://claude.ai/code/artifact/49da29e0-84e9-4ed9-b3ab-4042ca11c7ea

Compiled 12 September 2026 from all 15 repositories, the plugins installed on the
Mac mini, and the claude.ai account.

## Where you are decides what works

| Surface | Where it runs | What to know |
|---|---|---|
| **Repo** | Claude Code, opened in that project folder | Files committed to the repo. Travels with the project, to the Mac and to web sessions alike. Only loads for the repo it sits in. |
| **Mac** | Claude Code in Terminal, on the Mac mini only | Marketplace plugins live in a folder git ignores. They resolve to nothing in a web session. |
| **Web** | claude.ai, desktop app, phone | Attached to the account, so they follow you everywhere on claude.ai. They do not reach Claude Code in Terminal. |

## Skills in your repos (10)

Most start on their own when the work matches. To force one, type its name with a
slash. Standing rule from the hub CLAUDE.md: copy a skill you need everywhere into
every repo, never install it as a plugin.

| Skill | What it does | Call it | Lives in | By |
|---|---|---|---|---|
| `stop-slop` | Strips the tells out of writing: filler openers, adverbs, passive voice, binary contrasts, em dashes. Rewrites; it does not search. | `/stop-slop` | All 15 repos | [Hardik Pandya](https://github.com/hardikpandya/stop-slop) (MIT) |
| `slop-scan` | Greps a repo's copy and reports every tell as file and line number. Finds the lines; stop-slop fixes them. | `/slop-scan` | All 15 repos | Yours, built 19 Aug 2026 |
| `grill-me` | Interviews you about a plan or decision. Numbered questions one round at a time, each with a recommended answer, until nothing is left assumed. Claude looks the facts up; the decisions stay yours. | `/grill-me` | All 15 repos | [Matt Pocock](https://github.com/mattpocock/skills) (MIT) |
| `grilling` | The interview engine `grill-me` hands to. Vendored beside it because either one alone resolves to nothing. | `grill-me` calls it | All 15 repos | [Matt Pocock](https://github.com/mattpocock/skills) (MIT) |
| `i-have-adhd` | Reshapes the answer: next action first, numbered steps, no preamble, no recap, lists capped at five. Ends on "stop adhd mode". | `/i-have-adhd` | claude-code, job-hunting, kingtan-com-au | [Ayoub Ghriss](https://github.com/ayghri/i-have-adhd) (MIT) |
| `frontend-design` | Visual direction for new UI: palette, type pairing, layout, and the discipline to avoid templated defaults. Your one primary design skill. | `/frontend-design` | claude-code, kingtan-com-au | [Anthropic](https://github.com/anthropics/claude-plugins-official) |
| `workspace-audit` | Six pass spring clean of the estate: repo map, CLAUDE.md clashes, duplicates, skills inventory, stale branches, clone health. | `/workspace-audit` | claude-code | Yours, first run 9 Aug 2026 |
| `tailor-application` | Paste a role and job description; get back a rewritten resume hook, summary and cover letter. Locks your title to Digital Designer. | `/tailor-application` | claude-code | Yours |
| `kingtan-portfolio-entry` | Eleven step intake for new work on kingtan.com.au: blurb voice, locked service tags, image pipeline, SEO pass, redirects, screenshot checks. | `/kingtan-portfolio-entry` | kingtan-com-au | Yours |
| `tbo-a0-posters` | Turns a Bottle-O A0 brief workbook into InDesign Data Merge CSVs, then proofreads the finished PDF against the brief. | `/tbo-a0-posters` | metcash | Yours |

**Four skills now sit in all 15 repos**: `stop-slop`, `slop-scan`, `grill-me` and
`grilling`, all vendored on 12 September 2026.

## Plugins on the Mac (2)

Installed with `claude plugin install` at user scope, so they work in every folder
on that machine. They do not exist in a web session. Check what is on there with
`claude plugin list`.

| Plugin | What it does | Call it | By |
|---|---|---|---|
| `mattpocock-skills` | 25 engineering skills: spec and ticket flows, TDD, code review, domain modelling, bug diagnosis, merge conflicts. This one never installs in a cloud session, for the reason in the notes below. `grill-me` now reaches you from your repo copy instead. | `/mattpocock-skills:<name>`, Mac only | [Matt Pocock](https://github.com/mattpocock/skills) |
| `i-have-adhd` | The plugin version of the skill above. Adds a session hook that can switch the format on automatically, which a copied skill file cannot do. | `/i-have-adhd` | [Ayoub Ghriss](https://github.com/ayghri/i-have-adhd) |

## Skills on claude.ai (9)

Attached to your account. They follow you to the phone, the desktop app and web
sessions. Most start on their own. Naming one is the exception.

| Skill | What it does | Call it | By |
|---|---|---|---|
| `house-voice` | Your writing rules applied to everything Claude writes for you: no dashes, no emoji, second person, banned words, a close that points forward. | Runs automatically | Yours |
| `stop-slop` | The same writing rules as the repo copy, available everywhere on claude.ai without opening a project. | `/stop-slop` | [Hardik Pandya](https://github.com/hardikpandya/stop-slop) |
| `skill-creator` | Builds a new skill, improves an existing one, and tests whether its description triggers reliably. Use it when you catch yourself explaining the same process twice. | `/skill-creator` | [Anthropic](https://github.com/anthropics/skills) |
| `morning` | Your morning brief as a styled page, or set up to run itself on weekdays. | `/morning` | [Anthropic](https://github.com/anthropics/skills) |
| `import-memory` | Brings a memory export from another AI assistant into Claude's memory, added to what is there rather than replacing it. | `/import-memory` | [Anthropic](https://github.com/anthropics/skills) |
| `docx`, `pptx`, `xlsx`, `pdf` | Real Office and PDF files, read and written properly. Word documents with page numbers, PowerPoint decks, spreadsheets with live formulas, PDFs you can merge, split, fill or OCR. | Runs automatically when a file format is named | [Anthropic](https://github.com/anthropics/skills) |

## Connectors on claude.ai (3)

These reach outside the conversation into a real product.

| Plugin | What it does | By |
|---|---|---|
| `figma` | Reads your Figma files and writes back into them: pull a design into code, push a page into Figma, extract tokens and components, build a library. Paste a figma.com link to start. | [Figma](https://www.figma.com/) |
| `adobe-for-creativity` | Creative Cloud for images, vectors and video. Edits batches of assets at once and adapts one piece across platform sizes. | [Adobe](https://www.adobe.com/) |
| `design` | Design critique, design system management, UX writing, accessibility audits, research synthesis, developer handoff. | [Anthropic](https://github.com/anthropics/claude-plugins-official) |

## Runs without being asked (2 hooks)

Hooks live in a repo's `.claude/settings.json`. Claude Code runs them; you never
call them.

| Hook | When it fires | Where |
|---|---|---|
| `i-have-adhd-always` | On session start. Loads the ADHD format so you do not have to ask each time. | job-hunting |
| `slop-scan` on save | After every Write or Edit. Hands back any line that breaks the writing rules before the change is reported as done. | kingtan-com-au |

## Worth knowing

- **Enabling a plugin does not install it.** `.claude/settings.json` asks for
  `mattpocock-skills@claude-plugins-official` and that name is correct. The catch is
  in the marketplace entry: it uses `"source": "url"`, so installing needs a second
  clone on top of the marketplace fetch, and a fresh cloud container never runs that
  clone. That, not the Mac-only rule, is why `/grill-me` answered "Unknown command".
  Expect the same silence from any other `source: url` plugin.
- **Three repos were born on a session branch.** `metcash`, `Business` and `agents`
  each started inside a Claude session with no `main`. You gave `metcash` one and
  switched its default over on 12 September. `Business` and `agents` still run on a
  single `claude/*` branch each, which you chose to leave as it is.
- **`personal` is your only public repo.** This file sits on its front page, where it
  names your private repo names and your work. Nothing secret in it, and it was
  already readable before, but move it to `claude-code` if you would rather it stayed
  behind the wall.
- **Two copies of the same skill had drifted apart.** The `kingtan-com-au` copy of
  `scan.py` carried a fix (`underbelly` on the not-an-adverb list) that the hub copy
  never received. Nothing flagged it. All 15 copies are now byte-identical; if you
  edit one, edit them all.
- **i-have-adhd sits in 3 repos, frontend-design in 2.** Both would earn their place
  in more of them.
- **Installing is not loading.** A skill opens when you invoke it or when the work
  matches its description. Sitting in a folder does nothing on its own.
- **You deleted `ui-ux-pro-max`** on 9 August 2026, to keep one primary design skill
  and stop two competing for the same jobs. Still recoverable from the git history
  of `kingytan/claude-code`.

## Keeping this current

Run `/workspace-audit` in the `claude-code` repo. Its skills inventory pass covers
the same ground as this document.

Workspace rules: https://github.com/kingytan/claude-code/blob/main/CLAUDE.md
