#!/usr/bin/env bash
# Re-pull every vendored Agent Skill in .claude/skills/ from its upstream repo.
#
# Usage:
#   scripts/update-skills.sh            # update all skills
#   scripts/update-skills.sh impeccable # update only the named skill(s)
#
# Each skill folder is replaced wholesale with the upstream copy, its license
# file(s) are placed next to it, and an UPSTREAM file records the source repo,
# path and commit. Upstream code is only copied, never executed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/.claude/skills"

# name | repo | path to skill folder in repo | license source
#   license source: a repo-relative file (or several, comma-separated), or
#   "MIT:<holder>" for repos that declare MIT but ship no LICENSE file.
MANIFEST=$(cat <<'EOF'
frontend-design|anthropics/claude-plugins-official|plugins/frontend-design/skills/frontend-design|plugins/frontend-design/skills/frontend-design/LICENSE.txt
impeccable|pbakaus/impeccable|.claude/skills/impeccable|LICENSE,NOTICE.md
web-design-guidelines|vercel-labs/agent-skills|skills/web-design-guidelines|MIT:Vercel, Inc.
react-best-practices|vercel-labs/agent-skills|skills/react-best-practices|MIT:Vercel, Inc.
taste-skill|Leonxlnx/taste-skill|skills/taste-skill|LICENSE
ui-ux-pro-max|nextlevelbuilder/ui-ux-pro-max-skill|.claude/skills/ui-ux-pro-max|LICENSE
accessibility-audit|AccessLint/skills|plugins/accesslint/skills/accessibility-audit|MIT:AccessLint
accessibility-diff|AccessLint/skills|plugins/accesslint/skills/accessibility-diff|MIT:AccessLint
accessibility-fix|AccessLint/skills|plugins/accesslint/skills/accessibility-fix|MIT:AccessLint
accessibility-inspect|AccessLint/skills|plugins/accesslint/skills/accessibility-inspect|MIT:AccessLint
accessibility-scan|AccessLint/skills|plugins/accesslint/skills/accessibility-scan|MIT:AccessLint
shared|AccessLint/skills|plugins/accesslint/skills/shared|MIT:AccessLint
EOF
)
# Note: "shared" is not a skill. The AccessLint skills link to
# ../shared/methodology.md, so it must sit beside them.

write_mit() { # holder repo dest
  cat > "$3" <<EOF
MIT License

Copyright (c) $1

Upstream: https://github.com/$2
No LICENSE file is shipped in the upstream repository; it declares the MIT
license in its README (and package/plugin metadata). The standard MIT text is
reproduced here to keep the license next to the vendored copy.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$SKILLS_DIR"

SELECTED=("$@")

while IFS='|' read -r name repo path license; do
  [ -n "$name" ] || continue
  if [ "${#SELECTED[@]}" -gt 0 ]; then
    match=false
    for a in "${SELECTED[@]}"; do [ "$a" = "$name" ] && match=true; done
    $match || continue
  fi

  clone="$WORK/${repo//\//__}"
  if [ ! -d "$clone" ]; then
    echo "==> cloning $repo"
    git clone --quiet --depth 1 "https://github.com/$repo.git" "$clone"
  fi
  src="$clone/$path"
  if [ ! -d "$src" ]; then
    echo "!! $name: $path not found in $repo (upstream layout changed?)" >&2
    exit 1
  fi

  dest="$SKILLS_DIR/$name"
  rm -rf "$dest"
  cp -R "$src" "$dest"

  case "$license" in
    MIT:*) [ -e "$dest/LICENSE" ] || write_mit "${license#MIT:}" "$repo" "$dest/LICENSE" ;;
    *)
      IFS=',' read -ra files <<< "$license"
      for f in "${files[@]}"; do
        [ -e "$dest/$(basename "$f")" ] || cp "$clone/$f" "$dest/"
      done
      ;;
  esac

  commit="$(git -C "$clone" rev-parse HEAD)"
  printf 'repo: https://github.com/%s\npath: %s\ncommit: %s\n' "$repo" "$path" "$commit" > "$dest/UPSTREAM"
  echo "    $name <- $repo@${commit:0:7}"
done <<< "$MANIFEST"

echo "Done. Review with: git status .claude/skills"
