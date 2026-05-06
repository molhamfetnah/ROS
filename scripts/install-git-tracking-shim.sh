#!/usr/bin/env bash
set -euo pipefail

BASHRC="${HOME}/.bashrc"
MARK_START="# >>> ros git tracking shim >>>"
MARK_END="# <<< ros git tracking shim <<<"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SNIPPET="${REPO_ROOT}/docs/snippets/git-tracking-shim.bash"
SOURCE_LINE="[ -f \"$SNIPPET\" ] && source \"$SNIPPET\""

touch "$BASHRC"

if grep -Fq "$MARK_START" "$BASHRC"; then
  exit 0
fi

{
  printf '%s\n' "$MARK_START"
  printf '%s\n' "$SOURCE_LINE"
  printf '%s\n' "$MARK_END"
} >> "$BASHRC"
