# Git Status Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automatic ROS-parent-only tracking for `git status` that writes append-only history and latest snapshots without blocking normal git usage.

**Architecture:** Implement a small Bash collector script that parses `git status --porcelain=v1` and writes `.tracking/latest.json`, `.tracking/history.ndjson`, and `.tracking/latest.txt`. Add a Bash `git` shim snippet that runs the collector only for `status`/`st` at `/mnt/data/ros`, plus an idempotent installer that sources the shim from `~/.bashrc`. Keep submodules excluded by strict top-level path check.

**Tech Stack:** Bash, git porcelain output, jq (JSON construction), GNU coreutils.

---

## File Structure Plan

- Create: `scripts/track-git-status.sh` — collector and writer for tracking artifacts.
- Create: `scripts/install-git-tracking-shim.sh` — idempotent installer into `~/.bashrc`.
- Create: `session/docs/snippets/git-tracking-shim.bash` — shell function shim for `git`.
- Create: `scripts/tests/test-track-git-status.sh` — collector behavior test script.
- Create: `scripts/tests/test-git-tracking-shim.sh` — shim routing test script.
- Modify: `.gitignore` — ignore `.tracking/`.

---

### Task 1: Build collector with TDD for snapshot generation

**Files:**
- Create: `scripts/tests/test-track-git-status.sh`
- Create: `scripts/track-git-status.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Write failing test for snapshot/history creation**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="/mnt/data/ros"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/porcelain.txt" <<'EOF'
?? new.txt
 M changed.md
 D removed.log
R  old.py -> new.py
EOF

SCRIPT="$ROOT/scripts/track-git-status.sh"
if [ -x "$SCRIPT" ]; then
  "$SCRIPT" \
    --repo-root "$ROOT" \
    --branch "main" \
    --porcelain-file "$TMP/porcelain.txt" \
    --tracking-dir "$TMP/.tracking"
fi

test -f "$TMP/.tracking/latest.json"
test -f "$TMP/.tracking/history.ndjson"
test -f "$TMP/.tracking/latest.txt"
grep -q '"untracked":\["new.txt"\]' "$TMP/.tracking/latest.json"
grep -q '"modified":\["changed.md"\]' "$TMP/.tracking/latest.json"
grep -q '"deleted":\["removed.log"\]' "$TMP/.tracking/latest.json"
grep -q '"renamed":\["old.py -> new.py"\]' "$TMP/.tracking/latest.json"
```

- [ ] **Step 2: Run test to verify failure**

Run: `bash scripts/tests/test-track-git-status.sh`  
Expected: FAIL because `scripts/track-git-status.sh` does not exist yet.

- [ ] **Step 3: Write minimal collector implementation**

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=""
BRANCH=""
PORCELAIN_FILE=""
TRACKING_DIR=""
MAX_BYTES="${TRACKING_MAX_BYTES:-10485760}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root) REPO_ROOT="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --porcelain-file) PORCELAIN_FILE="$2"; shift 2 ;;
    --tracking-dir) TRACKING_DIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$TRACKING_DIR"
HISTORY="$TRACKING_DIR/history.ndjson"
LATEST_JSON="$TRACKING_DIR/latest.json"
LATEST_TXT="$TRACKING_DIR/latest.txt"

if [[ -f "$HISTORY" ]]; then
  size="$(wc -c < "$HISTORY" | tr -d ' ')"
  if [[ "$size" -gt "$MAX_BYTES" ]]; then
    mv "$HISTORY" "$TRACKING_DIR/history.$(date -u +%Y%m%dT%H%M%SZ).ndjson"
  fi
fi

mapfile -t UNTRACKED < <(awk '/^\?\? /{sub(/^\?\? /,""); print}' "$PORCELAIN_FILE")
mapfile -t MODIFIED  < <(awk '/^( M|M |MM)/{sub(/^../,""); sub(/^ /,""); print}' "$PORCELAIN_FILE")
mapfile -t DELETED   < <(awk '/^( D|D )/{sub(/^../,""); sub(/^ /,""); print}' "$PORCELAIN_FILE")
mapfile -t RENAMED   < <(awk '/^R/{sub(/^../,""); sub(/^ /,""); print}' "$PORCELAIN_FILE")

json="$(jq -cn \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg repo "$REPO_ROOT" \
  --arg branch "$BRANCH" \
  --argjson untracked "$(printf '%s\n' "${UNTRACKED[@]:-}" | jq -Rsc 'split("\n")[:-1]')" \
  --argjson modified  "$(printf '%s\n' "${MODIFIED[@]:-}"  | jq -Rsc 'split("\n")[:-1]')" \
  --argjson deleted   "$(printf '%s\n' "${DELETED[@]:-}"   | jq -Rsc 'split("\n")[:-1]')" \
  --argjson renamed   "$(printf '%s\n' "${RENAMED[@]:-}"   | jq -Rsc 'split("\n")[:-1]')" \
  '{timestamp:$ts,repo_root:$repo,branch:$branch,untracked:$untracked,modified:$modified,deleted:$deleted,renamed:$renamed}')"

printf '%s\n' "$json" > "$LATEST_JSON"
printf '%s\n' "$json" >> "$HISTORY"
{
  echo "timestamp: $(jq -r '.timestamp' "$LATEST_JSON")"
  echo "repo: $(jq -r '.repo_root' "$LATEST_JSON")"
  echo "branch: $(jq -r '.branch' "$LATEST_JSON")"
  echo "untracked: $(jq -r '.untracked | length' "$LATEST_JSON")"
  echo "modified: $(jq -r '.modified | length' "$LATEST_JSON")"
  echo "deleted: $(jq -r '.deleted | length' "$LATEST_JSON")"
  echo "renamed: $(jq -r '.renamed | length' "$LATEST_JSON")"
} > "$LATEST_TXT"
```

- [ ] **Step 4: Ignore tracking artifacts in git**

Append this line to `.gitignore`:

```gitignore
.tracking/
```

- [ ] **Step 5: Run test to verify pass**

Run: `bash scripts/tests/test-track-git-status.sh`  
Expected: PASS (exit code 0).

- [ ] **Step 6: Commit**

```bash
git add .gitignore scripts/track-git-status.sh scripts/tests/test-track-git-status.sh
git commit -m "feat: add git status collector and artifact snapshots"
```

---

### Task 2: Add collector safeguards (rotation + non-blocking behavior)

**Files:**
- Modify: `scripts/tests/test-track-git-status.sh`
- Modify: `scripts/track-git-status.sh`

- [ ] **Step 1: Add failing tests for rotation and malformed input tolerance**

Add to `scripts/tests/test-track-git-status.sh`:

```bash
# rotation test
python3 - <<'PY'
from pathlib import Path
p = Path(".tmp-history")
p.mkdir(exist_ok=True)
(p/"history.ndjson").write_text("x"*120)
PY
"$ROOT/scripts/track-git-status.sh" \
  --repo-root "$ROOT" \
  --branch "main" \
  --porcelain-file "$TMP/porcelain.txt" \
  --tracking-dir ".tmp-history" \
  TRACKING_MAX_BYTES=10
test -f .tmp-history/history.ndjson
ls .tmp-history/history.*.ndjson >/dev/null
rm -rf .tmp-history
```

- [ ] **Step 2: Run test to verify failure**

Run: `bash scripts/tests/test-track-git-status.sh`  
Expected: FAIL until environment/rotation handling is corrected.

- [ ] **Step 3: Implement minimal fix for configurable rotation threshold and robust empty arrays**

Update `scripts/track-git-status.sh` to:

```bash
MAX_BYTES="${TRACKING_MAX_BYTES:-10485760}"

to_json_array() {
  if [[ $# -eq 0 ]]; then
    printf '[]'
  else
    printf '%s\n' "$@" | jq -Rsc 'split("\n")[:-1]'
  fi
}
```

and replace the four `--argjson ...` generators with `to_json_array`.

- [ ] **Step 4: Re-run test to verify pass**

Run: `bash scripts/tests/test-track-git-status.sh`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add scripts/track-git-status.sh scripts/tests/test-track-git-status.sh
git commit -m "fix: harden collector rotation and array handling"
```

---

### Task 3: Add transparent git shim and installer (ROS parent only)

**Files:**
- Create: `session/docs/snippets/git-tracking-shim.bash`
- Create: `scripts/install-git-tracking-shim.sh`
- Create: `scripts/tests/test-git-tracking-shim.sh`

- [ ] **Step 1: Write failing shim-routing test**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="/mnt/data/ros"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/fake-git" <<'EOF'
#!/usr/bin/env bash
echo "REAL_GIT $*" >> "$TMP/out.log"
EOF
chmod +x "$TMP/fake-git"

export REAL_GIT_BIN="$TMP/fake-git"
export TRACKER_SCRIPT="$ROOT/scripts/track-git-status.sh"
source "$ROOT/session/docs/snippets/git-tracking-shim.bash"

git status
grep -q "REAL_GIT status" "$TMP/out.log"
```

- [ ] **Step 2: Run test to verify failure**

Run: `bash scripts/tests/test-git-tracking-shim.sh`  
Expected: FAIL because shim snippet does not exist yet.

- [ ] **Step 3: Implement shim snippet**

`session/docs/snippets/git-tracking-shim.bash`:

```bash
git() {
  local real_git="${REAL_GIT_BIN:-/usr/bin/git}"
  local tracker="${TRACKER_SCRIPT:-/mnt/data/ros/scripts/track-git-status.sh}"
  local cmd="${1:-}"

  if [[ "$cmd" == "status" || "$cmd" == "st" ]]; then
    local top
    top="$("$real_git" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ "$top" == "/mnt/data/ros" ]]; then
      local tmp porcelain branch
      tmp="$(mktemp)"
      porcelain="$tmp.porcelain"
      branch="$("$real_git" -C "$top" branch --show-current 2>/dev/null || echo unknown)"
      "$real_git" -C "$top" status --porcelain=v1 > "$porcelain" || true
      if ! "$tracker" --repo-root "$top" --branch "$branch" --porcelain-file "$porcelain" --tracking-dir "$top/.tracking"; then
        echo "[tracking-warning] failed to write tracking artifacts" >&2
      fi
      rm -f "$tmp" "$porcelain"
    fi
  fi
  "$real_git" "$@"
}
```

- [ ] **Step 4: Implement installer helper**

`scripts/install-git-tracking-shim.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

BASHRC="${HOME}/.bashrc"
MARK_START="# >>> ros git tracking shim >>>"
MARK_END="# <<< ros git tracking shim <<<"
SNIPPET="/mnt/data/ros/session/docs/snippets/git-tracking-shim.bash"

touch "$BASHRC"
if grep -q "$MARK_START" "$BASHRC"; then
  exit 0
fi

{
  echo "$MARK_START"
  echo "[ -f \"$SNIPPET\" ] && source \"$SNIPPET\""
  echo "$MARK_END"
} >> "$BASHRC"
```

- [ ] **Step 5: Run shim test to verify pass**

Run: `bash scripts/tests/test-git-tracking-shim.sh`  
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add session/docs/snippets/git-tracking-shim.bash scripts/install-git-tracking-shim.sh scripts/tests/test-git-tracking-shim.sh
git commit -m "feat: add transparent git status tracking shim and installer"
```

---

### Task 4: Install + end-to-end verification in ROS parent repo

**Files:**
- Modify: none (runtime verification and shell setup)

- [ ] **Step 1: Install shim idempotently**

Run:

```bash
bash /mnt/data/ros/scripts/install-git-tracking-shim.sh
source ~/.bashrc
```

Expected: no duplicate shim block entries.

- [ ] **Step 2: Create representative file-state changes for validation**

Run:

```bash
cd /mnt/data/ros
echo "tmp" > .tracking-e2e-untracked.tmp
touch .tracking-e2e-modified.tmp && git add .tracking-e2e-modified.tmp && echo "m" >> .tracking-e2e-modified.tmp
```

- [ ] **Step 3: Trigger tracking through git status**

Run:

```bash
git status
```

Expected:
- `.tracking/latest.json` exists
- `.tracking/history.ndjson` appended
- `.tracking/latest.txt` updated

- [ ] **Step 4: Validate tracker does not run in submodule**

Run:

```bash
cd /mnt/data/ros/program/benchmark-core
git status
test ! -d .tracking
```

Expected: PASS (no local `.tracking` folder in submodule).

- [ ] **Step 5: Cleanup temporary e2e files**

Run:

```bash
cd /mnt/data/ros
git restore --staged .tracking-e2e-modified.tmp || true
rm -f .tracking-e2e-untracked.tmp .tracking-e2e-modified.tmp
```

- [ ] **Step 6: Commit final operational docs note (if needed)**

If README operational note is added:

```bash
git add README.md
git commit -m "docs: add git tracking shim usage note"
```

---

## Spec Coverage Check (self-review)

1. **ROS parent only:** Covered via strict top-level check in shim (Task 3).
2. **Track untracked/modified/deleted/renamed:** Covered in collector parsing (Task 1).
3. **Append history + latest snapshot + text summary:** Covered in artifact writes (Task 1).
4. **Non-blocking behavior:** Covered via warning + passthrough (Task 3).
5. **Rotation policy:** Covered in Task 2.
6. **Submodule exclusion:** Covered in Task 4 explicit check.
7. **No placeholders:** All file paths, code, and commands are explicit.

