#!/usr/bin/env bash
# Link this repo's skills into every agent runtime that reads the Agent Skills format.
#
#   ./install.sh                 link into the current directory (project scope)
#   ./install.sh ~/work/myrepo   link into that project
#   ./install.sh --global        link into the per-user directories
#   ./install.sh --list          show what is linked where
#   ./install.sh --uninstall …   remove links this script created
#
# Every runtime below follows symlinks, so one canonical copy in skills/ serves all of them.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
MODE=install
SCOPE=project
TARGET="$PWD"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)    SCOPE=global ;;
    --list)      MODE=list ;;
    --uninstall) MODE=uninstall ;;
    -h|--help)   sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          echo "unknown option: $1" >&2; exit 1 ;;
    *)           TARGET="$1" ;;
  esac
  shift
done

# Project scope needs only two directories: Claude Code reads .claude/skills, while Codex,
# Antigravity and omp all read .agents/skills. omp additionally reads both of them.
if [[ "$SCOPE" == project ]]; then
  [[ -d "$TARGET" ]] || { echo "not a directory: $TARGET" >&2; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  DESTS=("$TARGET/.claude/skills" "$TARGET/.agents/skills")
else
  DESTS=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.gemini/config/skills")
fi

skills() { find "$SRC" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' \; -print | sort; }

case "$MODE" in
list)
  for d in "${DESTS[@]}"; do
    echo "$d"
    [[ -d "$d" ]] || { echo "  (absent)"; continue; }
    for l in "$d"/*; do
      [[ -L "$l" ]] || continue
      [[ "$(readlink "$l")" == "$SRC"/* ]] && echo "  $(basename "$l") -> $(readlink "$l")"
    done
  done
  ;;
uninstall)
  n=0
  for d in "${DESTS[@]}"; do
    [[ -d "$d" ]] || continue
    for l in "$d"/*; do
      [[ -L "$l" ]] || continue
      if [[ "$(readlink "$l")" == "$SRC"/* ]]; then rm "$l"; n=$((n+1)); fi
    done
  done
  echo "removed $n link(s)"
  ;;
install)
  count=0
  for d in "${DESTS[@]}"; do
    mkdir -p "$d"
    while IFS= read -r s; do
      name="$(basename "$s")"
      link="$d/$name"
      if [[ -L "$link" ]]; then
        rm "$link"
      elif [[ -e "$link" ]]; then
        echo "skip $link (a real file or directory already owns that name)" >&2
        continue
      fi
      ln -s "$s" "$link"
      count=$((count+1))
    done < <(skills)
  done
  echo "linked $count skill path(s) into: ${DESTS[*]}"
  echo
  echo "Verify discovery without guessing:"
  echo "  claude -p ok --output-format stream-json --verbose | head -1"
  ;;
esac
