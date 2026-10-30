# frontend-kit

A reusable starting point for new web projects with Claude Code: vendored design and accessibility Agent Skills, MCP servers for component generation and browser checks, a `CLAUDE.md` that wires them together, and a design brief template.

## Use it

1. Create a new repo from this template (or copy `.claude/`, `.mcp.json`, `CLAUDE.md`, `design/`, `scripts/`).
2. Fill in `design/brief.md` and drop screenshots/moodboards into `design/references/`.
3. Export MCP keys in your shell (see [MCP servers](#mcp-servers)).
4. Run `claude` in the project. `CLAUDE.md` tells it to read the brief, pick a design system with `ui-ux-pro-max`, build with `frontend-design` + `impeccable`, and check the result in a browser.

## Layout

```
.claude/skills/        vendored Agent Skills (one folder each, LICENSE + UPSTREAM inside)
.mcp.json              21st.dev Magic + Playwright MCP (keys from env vars only)
CLAUDE.md              project instructions for Claude
design/brief.md        fill-in design brief
design/references/     put reference images / notes here
scripts/update-skills.sh   re-pull every skill from upstream
```

## Skills

| Skill (`.claude/skills/…`) | What it does | Upstream source | License | Runtime needs |
|---|---|---|---|---|
| `frontend-design` | Creative direction for distinctive, non-generic UI | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/frontend-design) `plugins/frontend-design/skills/frontend-design` ¹ | Apache-2.0 | none |
| `impeccable` | Design craft rules, commands, anti-pattern detection | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) `.claude/skills/impeccable` | Apache-2.0 (+ `NOTICE.md`) | `sh`; launcher downloads its CLI binary on first run (network). Live-browser mode needs a browser |
| `web-design-guidelines` | Review UI against Vercel's Web Interface Guidelines | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) | MIT ² | fetches the guidelines from GitHub at run time (network) |
| `react-best-practices` | React / Next.js performance & code rules | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) | MIT ² | none |
| `taste-skill` (`design-taste-frontend`) | Art direction from curated reference sites; anti-"AI slop" | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) `skills/taste-skill` | MIT | Node 22+ and Chrome/Edge for its scripts |
| `ui-ux-pro-max` | Searchable design-system database (styles, palettes, fonts, UX rules) | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) `.claude/skills/ui-ux-pro-max` (full folder incl. `data/`, `scripts/`) | MIT | Python 3 |
| `accessibility-scan` | Rule-engine a11y scan of one live page | [AccessLint/skills](https://github.com/AccessLint/skills) `plugins/accesslint/skills/…` | MIT ² | Node + Chrome (local computer) |
| `accessibility-inspect` | Keyboard / screen-reader / reflow checks | ″ | MIT ² | Node + Chrome (local computer) |
| `accessibility-audit` | WCAG-EM site-wide conformance audit | ″ | MIT ² | Node + Chrome (local computer) |
| `accessibility-fix` | Apply a11y fixes and verify | ″ | MIT ² | Node + Chrome to verify |
| `accessibility-diff` | A11y regressions vs. baseline/branch | ″ | MIT ² | Node + Chrome (local computer) |
| `shared` | *Not a skill* — `methodology.md` linked by the AccessLint skills as `../shared/` | ″ | MIT ² | — |

¹ The task named `anthropics/claude-code` `plugins/frontend-design`; that plugin has moved. `anthropics/claude-code`'s marketplace now installs it from `anthropics/claude-plugins-official`, which is where it's copied from. (`anthropics/claude-code` itself is "All rights reserved", so nothing is copied from it.)

² Upstream declares MIT in its README / metadata but ships no LICENSE file, so `update-skills.sh` writes the standard MIT text into the skill folder, noting where the declaration comes from.

Each skill folder has an `UPSTREAM` file with the exact repo, path and commit it was copied from.

## MCP servers

Configured in `.mcp.json`. No secrets are stored in the file; Claude Code expands `${VAR}` from your environment.

| Server | What | Config | Needs |
|---|---|---|---|
| `21st-magic` | 21st.dev Magic (now the "21st MCP") — UI component search & generation | HTTP `https://21st.dev/api/mcp`, header `x-api-key: ${API_KEY_21ST}` (the form recommended in [21st-dev/magic-mcp](https://github.com/21st-dev/magic-mcp)) | `API_KEY_21ST` env var — get a key at [21st.dev/mcp](https://21st.dev/mcp). Network only; no local browser |
| `playwright` | Drive a real browser: open pages, screenshot, click | `npx -y @playwright/mcp@latest` ([microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)) | Node + a local Chromium/Chrome — **needs a computer** with a browser (works in Claude Code on your machine, or in cloud containers that ship Chromium) |

```bash
export API_KEY_21ST=...   # e.g. in ~/.zshrc, or a git-ignored .env you source (see .env.example)
```

### Which pieces need a computer

- **Need a local computer / browser:** Playwright MCP, the AccessLint skills, `taste-skill` scripts, `impeccable` live-browser mode.
- **Need network only:** 21st Magic MCP, `web-design-guidelines`, `impeccable` (first-run binary download).
- **Run anywhere Claude reads files:** `frontend-design`, `react-best-practices`, `ui-ux-pro-max` (Python 3), the rule/reference parts of everything else.

## Updating skills

```bash
scripts/update-skills.sh                 # re-pull all skills
scripts/update-skills.sh impeccable      # or just some
git diff --stat .claude/skills           # review, then commit
```

The script shallow-clones each upstream repo into a temp dir, replaces the skill folder wholesale, places the license next to it, and rewrites `UPSTREAM`. It copies files only — it never runs upstream code. Sources are listed in the `MANIFEST` at the top of the script; edit it to add or drop a skill.

Quick check that `ui-ux-pro-max` is intact:

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "landing page" --domain style
```

## License

The vendored skills keep their own licenses (see each folder). Everything else in this repo is yours to license as you like.
