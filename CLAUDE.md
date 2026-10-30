# CLAUDE.md

This repo is a frontend starter kit. Skills live in `.claude/skills/`; MCP servers are in `.mcp.json`.

## Before building any UI

1. **Read the brief.** Read `design/brief.md` and every file in `design/references/` (images, screenshots, notes, links). If the brief is still the unfilled template, ask the user for the missing essentials (audience, aesthetic, palette, fonts) before designing — don't invent a direction silently.
2. **Pick a design system first with `ui-ux-pro-max`.** Before writing UI code, generate or search a design system that fits the brief:
   ```bash
   python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<product type + mood words>" --design-system -p "<Project>"
   python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --domain style   # also: color, typography, landing, ux, ...
   ```
   Where the brief and the generated system disagree, the brief wins. Record the chosen style, palette, type scale and spacing as CSS variables/tokens before building components.

## While building UI

- **Always use the `frontend-design` and `impeccable` skills for any UI work** (pages, components, restyles, polish). `frontend-design` sets the creative direction; `impeccable` supplies the craft rules, commands and anti-pattern checks. Follow both.
- Use the other skills where they apply:
  - `taste-skill` — extra art direction and a guard against generic "AI-looking" layouts.
  - `web-design-guidelines` — review UI against Vercel's Web Interface Guidelines.
  - `react-best-practices` — React / Next.js code and performance.
  - `accessibility-scan`, `accessibility-inspect`, `accessibility-fix`, `accessibility-audit`, `accessibility-diff` — accessibility (WCAG 2.2) checks and fixes.
- Use the `21st-magic` MCP for component inspiration or generation when the key is configured; restyle anything it produces to match the brief and tokens.

## After building UI

- **Check the result in a browser whenever one is available** (Playwright MCP, the built-in browser, or Claude in Chrome). Run the dev server, open the page, take screenshots at mobile (~375px) and desktop (~1440px) widths, and compare against `design/brief.md` and `design/references/`. Fix what you see before calling the work done.
- Run an accessibility pass (`accessibility-scan`, then `accessibility-fix`) on new or changed pages.
- If no browser is available, say so explicitly in your summary rather than implying the UI was visually verified.

## Maintenance

- Vendored skills are refreshed with `scripts/update-skills.sh`; don't hand-edit files under `.claude/skills/` (changes will be overwritten). Each skill folder has an `UPSTREAM` file with its source repo and commit.
- Never commit API keys. MCP keys come from environment variables only (see `.env.example`).
