#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$ROOT/scripts/tests/.tmp-track-git-status"
SCRIPT="$ROOT/scripts/track-git-status.sh"

rm -rf "$WORK"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/porcelain.txt" <<'PORCELAIN'
?? new.txt
 M changed.md
 D removed.log
R  old.py -> new.py
PORCELAIN

if [[ -x "$SCRIPT" ]]; then
  "$SCRIPT" \
    --repo-root "$ROOT" \
    --branch "main" \
    --porcelain-file "$WORK/porcelain.txt" \
    --tracking-dir "$WORK/.tracking"
fi

test -f "$WORK/.tracking/latest.json"
test -f "$WORK/.tracking/history.ndjson"
test -f "$WORK/.tracking/latest.txt"

jq -e '.untracked == ["new.txt"]' "$WORK/.tracking/latest.json" >/dev/null
jq -e '.modified == ["changed.md"]' "$WORK/.tracking/latest.json" >/dev/null
jq -e '.deleted == ["removed.log"]' "$WORK/.tracking/latest.json" >/dev/null
jq -e '.renamed == ["old.py -> new.py"]' "$WORK/.tracking/latest.json" >/dev/null

jq -e '.untracked == ["new.txt"]' "$WORK/.tracking/history.ndjson" >/dev/null

grep -q '^untracked: 1$' "$WORK/.tracking/latest.txt"
grep -q '^modified: 1$' "$WORK/.tracking/latest.txt"
grep -q '^deleted: 1$' "$WORK/.tracking/latest.txt"
grep -q '^renamed: 1$' "$WORK/.tracking/latest.txt"
