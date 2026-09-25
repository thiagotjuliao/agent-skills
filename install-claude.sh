#!/usr/bin/env bash
# Installs the skills in this repository for Claude Code.
#
#   usage: ./install-claude.sh [skill ...] [--update] [--check]
#
#   skill ...   only these skills (directory names under skills/); default: all
#   --update    replace installed skills that differ from this repository
#   --check     write nothing; exit 1 if any skill is missing or differs
#
# Claude Code reads personal skills from ~/.claude/skills/<name>/ (or from
# $CLAUDE_CONFIG_DIR/skills when that is set). This copies each skill there.
#
# The repository is the source of truth, but an installed copy may have been
# edited in place, and that edit would be lost by a blind copy. So a skill that
# is missing is installed; one that differs is reported with its diff and only
# replaced under --update. Skills installed from anywhere else are never
# touched.
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"

UPDATE=0; CHECK=0; WANTED=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) UPDATE=1 ;;
    --check)  CHECK=1 ;;
    -*) die "unknown flag: $1" ;;
    *) WANTED+=("$1") ;;
  esac
  shift
done

if [[ ${#WANTED[@]} -eq 0 ]]; then
  while IFS= read -r d; do WANTED+=("$d"); done < <(cd "$HERE/skills" && ls -d */ | tr -d /)
fi

# Line endings are the checkout's business, not a difference.
same_tree() { # <a> <b>
  diff -r --strip-trailing-cr -q "$1" "$2" >/dev/null 2>&1
}

installed=0; same=0; updated=0; drift=0
echo "skills -> $DEST"
for name in "${WANTED[@]}"; do
  src="$HERE/skills/$name"
  [[ -f "$src/SKILL.md" ]] || die "no such skill: $name"
  dst="$DEST/${name:?}"
  if [[ ! -d "$dst" ]]; then
    if [[ $CHECK -eq 1 ]]; then
      echo "  missing   $name"; drift=$((drift + 1))
    else
      mkdir -p "$DEST"; cp -r "$src" "$dst"
      echo "  installed $name"; installed=$((installed + 1))
    fi
  elif same_tree "$src" "$dst"; then
    echo "  same      $name"; same=$((same + 1))
  elif [[ $UPDATE -eq 1 && $CHECK -eq 0 ]]; then
    diff -r --strip-trailing-cr -u "$dst" "$src" | sed 's/^/      /' || true
    rm -rf "${dst:?}"; cp -r "$src" "$dst"
    echo "  updated   $name"; updated=$((updated + 1))
  else
    echo "  DIFFERS   $name"; drift=$((drift + 1))
    diff -r --strip-trailing-cr -u "$dst" "$src" | sed 's/^/      /' || true
  fi
done

echo
echo "installed $installed, updated $updated, same $same, differs/missing $drift"
if [[ $drift -gt 0 ]]; then
  [[ $CHECK -eq 1 ]] && exit 1
  echo "run again with --update to replace the installed copies shown above"
fi
exit 0
