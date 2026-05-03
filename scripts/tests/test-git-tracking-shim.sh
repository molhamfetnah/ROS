#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TRACKED_ROOT="/mnt/data/ros"
TMP_BASE="$REPO_ROOT/scripts/tests/.tmp-git-shim-test-$$"
trap 'rm -rf "$TMP_BASE"' EXIT
mkdir -p "$TMP_BASE"

REAL_GIT="$TMP_BASE/fake-git"
BIN_DIR="$TMP_BASE/bin"
TRACKER="$TMP_BASE/fake-tracker.sh"
REAL_LOG="$TMP_BASE/real.log"
TRACKER_LOG="$TMP_BASE/tracker.log"
WARN_LOG="$TMP_BASE/warn.log"

mkdir -p "$BIN_DIR"

cat > "$REAL_GIT" <<'FAKEGIT'
#!/usr/bin/env bash
set -euo pipefail
: "${REAL_LOG:?}"
if [[ "${1:-}" == "-C" && "${3:-}" == "rev-parse" && "${4:-}" == "--show-toplevel" ]]; then
  printf '%s\n' "${FAKE_TOPLEVEL:-$2}"
  exit 0
fi
if [[ "${1:-}" == "rev-parse" && "${2:-}" == "--show-toplevel" ]]; then
  printf '%s\n' "${FAKE_TOPLEVEL:-$PWD}"
  exit 0
fi
if [[ "${1:-}" == "-C" && "${3:-}" == "branch" && "${4:-}" == "--show-current" ]]; then
  printf '%s\n' "${FAKE_BRANCH:-main}"
  exit 0
fi
if [[ "${1:-}" == "-C" && "${3:-}" == "status" && "${4:-}" == "--porcelain=v1" ]]; then
  printf '%s\n' "${FAKE_PORCELAIN_LINE:-?? new.txt}"
  exit 0
fi
printf 'REAL_GIT %s\n' "$*" >> "$REAL_LOG"
if [[ "${1:-}" == "-C" && ( "${3:-}" == "status" || "${3:-}" == "st" ) ]]; then
  printf 'REAL_STATUS\n'
fi
if [[ "${1:-}" == "status" || "${1:-}" == "st" ]]; then
  printf 'REAL_STATUS\n'
fi
FAKEGIT
chmod +x "$REAL_GIT"
cp "$REAL_GIT" "$BIN_DIR/git"

cat > "$TRACKER" <<'FAKETRACKER'
#!/usr/bin/env bash
set -euo pipefail
: "${TRACKER_LOG:?}"
printf 'TRACKER %s\n' "$*" >> "$TRACKER_LOG"
if [[ "${TRACKER_FAIL:-0}" == "1" ]]; then
  exit 7
fi
FAKETRACKER
chmod +x "$TRACKER"

export REAL_GIT_BIN="$REAL_GIT"
export TRACKER_SCRIPT="$TRACKER"
export REAL_LOG
export TRACKER_LOG
export FAKE_BRANCH="main"
export PATH="$BIN_DIR:$PATH"

# RED trigger if shim does not exist yet.
# shellcheck disable=SC1091
source "$REPO_ROOT/session/docs/snippets/git-tracking-shim.bash"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
FAKE_TOPLEVEL="$TRACKED_ROOT" git log --oneline >/dev/null

grep -Fq "REAL_GIT log --oneline" "$REAL_LOG"
if [[ -s "$TRACKER_LOG" ]]; then
  echo "tracker should not run for non-status commands" >&2
  exit 1
fi

: > "$REAL_LOG"
: > "$TRACKER_LOG"
FAKE_TOPLEVEL="$TRACKED_ROOT" git status >"$TMP_BASE/status.out"
grep -Fq "REAL_STATUS" "$TMP_BASE/status.out"
grep -Fq "REAL_GIT status" "$REAL_LOG"
grep -Fq "TRACKER --repo-root $TRACKED_ROOT --branch main" "$TRACKER_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
FAKE_TOPLEVEL="$TRACKED_ROOT" git st >/dev/null
grep -Fq "REAL_GIT st" "$REAL_LOG"
grep -Fq "TRACKER --repo-root $TRACKED_ROOT --branch main" "$TRACKER_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
FAKE_TOPLEVEL="$TRACKED_ROOT" git -C "$TRACKED_ROOT" status >"$TMP_BASE/status-with-global.out"
grep -Fq "REAL_STATUS" "$TMP_BASE/status-with-global.out"
grep -Fq "REAL_GIT -C $TRACKED_ROOT status" "$REAL_LOG"
grep -Fq "TRACKER --repo-root $TRACKED_ROOT --branch main" "$TRACKER_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
: > "$WARN_LOG"
REAL_GIT_BIN="git" FAKE_TOPLEVEL="$TRACKED_ROOT" git status >"$TMP_BASE/status-real-git-bin-git.out" 2>"$WARN_LOG"
grep -Fq "REAL_STATUS" "$TMP_BASE/status-real-git-bin-git.out"
grep -Fq "REAL_GIT status" "$REAL_LOG"
grep -Fq "unsafe REAL_GIT_BIN value: git" "$WARN_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
: > "$WARN_LOG"
REAL_GIT_BIN="fake-git" FAKE_TOPLEVEL="$TRACKED_ROOT" git status >"$TMP_BASE/status-real-git-bin-relative.out" 2>"$WARN_LOG"
grep -Fq "REAL_STATUS" "$TMP_BASE/status-real-git-bin-relative.out"
grep -Fq "REAL_GIT status" "$REAL_LOG"
grep -Fq "unsafe REAL_GIT_BIN value: fake-git" "$WARN_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
TRACKER_FAIL=1 FAKE_TOPLEVEL="$TRACKED_ROOT" git status >"$TMP_BASE/fail.out" 2>"$TMP_BASE/fail.err"
grep -Fq "REAL_STATUS" "$TMP_BASE/fail.out"
grep -Fq "[tracking-warning] failed to write tracking artifacts" "$TMP_BASE/fail.err"
grep -Fq "REAL_GIT status" "$REAL_LOG"

: > "$REAL_LOG"
: > "$TRACKER_LOG"
FAKE_TOPLEVEL="$TMP_BASE/not-ros" git status >/dev/null
grep -Fq "REAL_GIT status" "$REAL_LOG"
if [[ -s "$TRACKER_LOG" ]]; then
  echo "tracker should not run outside tracked root" >&2
  exit 1
fi

ORIG_HOME="${HOME:-}"
export HOME="$TMP_BASE/home"
mkdir -p "$HOME"
: > "$HOME/.bashrc"

"$REPO_ROOT/scripts/install-git-tracking-shim.sh"
"$REPO_ROOT/scripts/install-git-tracking-shim.sh"

start_count="$(grep -Fc '# >>> ros git tracking shim >>>' "$HOME/.bashrc")"
end_count="$(grep -Fc '# <<< ros git tracking shim <<<' "$HOME/.bashrc")"
line_count="$(grep -Fc '[ -f "/mnt/data/ros/session/docs/snippets/git-tracking-shim.bash" ] && source "/mnt/data/ros/session/docs/snippets/git-tracking-shim.bash"' "$HOME/.bashrc")"

[[ "$start_count" -eq 1 ]]
[[ "$end_count" -eq 1 ]]
[[ "$line_count" -eq 1 ]]

if [[ -n "$ORIG_HOME" ]]; then
  export HOME="$ORIG_HOME"
fi
