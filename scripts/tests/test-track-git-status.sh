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

ROTATION_DIR="$WORK/.rotation"
mkdir -p "$ROTATION_DIR"
python3 - "$ROTATION_DIR/history.ndjson" <<'PY'
from pathlib import Path
import sys

Path(sys.argv[1]).write_text("x" * 120, encoding="utf-8")
PY

TRACKING_MAX_BYTES=10 "$SCRIPT" \
  --repo-root "$ROOT" \
  --branch "main" \
  --porcelain-file "$WORK/porcelain.txt" \
  --tracking-dir "$ROTATION_DIR"

test -f "$ROTATION_DIR/history.ndjson"
ls "$ROTATION_DIR"/history.*.ndjson >/dev/null

FAKE_BIN="$WORK/fake-bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/date" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "-u" ]]; then
  shift
fi

case "${1:-}" in
  +%Y%m%dT%H%M%SZ)
    printf '20000101T000000Z\n'
    ;;
  +%Y-%m-%dT%H:%M:%SZ)
    printf '2000-01-01T00:00:00Z\n'
    ;;
  *)
    /usr/bin/date -u "${1:-}"
    ;;
esac
SH
chmod +x "$FAKE_BIN/date"

COLLISION_DIR="$WORK/.rotation-collision"
mkdir -p "$COLLISION_DIR"
python3 - "$COLLISION_DIR/history.ndjson" <<'PY'
from pathlib import Path
import sys

Path(sys.argv[1]).write_text("x" * 120, encoding="utf-8")
PY

PATH="$FAKE_BIN:$PATH" TRACKING_MAX_BYTES=10 "$SCRIPT" \
  --repo-root "$ROOT" \
  --branch "main" \
  --porcelain-file "$WORK/porcelain.txt" \
  --tracking-dir "$COLLISION_DIR"

PATH="$FAKE_BIN:$PATH" TRACKING_MAX_BYTES=10 "$SCRIPT" \
  --repo-root "$ROOT" \
  --branch "main" \
  --porcelain-file "$WORK/porcelain.txt" \
  --tracking-dir "$COLLISION_DIR"

mapfile -t ROTATED_FILES < <(find "$COLLISION_DIR" -maxdepth 1 -type f -name 'history.*.ndjson' | sort)
test "${#ROTATED_FILES[@]}" -eq 2

: > "$WORK/porcelain-empty.txt"
"$SCRIPT" \
  --repo-root "$ROOT" \
  --branch "main" \
  --porcelain-file "$WORK/porcelain-empty.txt" \
  --tracking-dir "$WORK/.tracking-empty"

jq -e '.untracked == []' "$WORK/.tracking-empty/latest.json" >/dev/null
jq -e '.modified == []' "$WORK/.tracking-empty/latest.json" >/dev/null
jq -e '.deleted == []' "$WORK/.tracking-empty/latest.json" >/dev/null
jq -e '.renamed == []' "$WORK/.tracking-empty/latest.json" >/dev/null
