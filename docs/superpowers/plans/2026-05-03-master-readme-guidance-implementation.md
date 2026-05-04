# Master README Guidance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the root README into a comprehensive, command-driven onboarding and day-2 operations guide for the ROS parent repo and its submodule architecture.

**Architecture:** Keep one authoritative root README with a strict section hierarchy: overview, topology, quickstart, full setup, operations, troubleshooting, contribution flow, and references. Use command-first instructions with explicit path context and verification checkpoints. Avoid duplicating deep technical docs by linking to existing spec/plan artifacts where detail already exists.

**Tech Stack:** Markdown, Git/GitHub CLI command recipes, shell command verification checkpoints.

---

## File Structure Plan

- Modify: `/mnt/data/ros/README.md` — replace current minimal content with the full professional guidance manual.
- Verify references only (no content changes expected):
  - `/mnt/data/ros/docs/superpowers/specs/2026-05-03-master-readme-guidance-design.md`
  - `/mnt/data/ros/program/research-program-index/README.md`
  - `/mnt/data/ros/program/benchmark-core/README.md`
  - `/mnt/data/ros/.gitmodules`

---

### Task 1: Replace README with approved architecture skeleton

**Files:**
- Modify: `/mnt/data/ros/README.md`

- [ ] **Step 1: Write the new top-level README structure**

Replace `README.md` contents with this exact initial skeleton:

```markdown
# ROS Program Workspace

Professional operating manual for the ROS parent repository and its managed multi-repo research program.

## 1. What This Repository Is

This parent repository orchestrates the full program workspace, shared workflows, and submodule pointers for domain repositories under `program/`.

It is the control plane for:
- repository topology
- shared workflows and guidance
- reproducible workspace bootstrap
- integration flow across subrepos

It is **not** where all implementation code lives; implementation is distributed in submodules.

## 2. Repository Topology

### 2.1 Parent Repo Responsibilities
- root-level orchestration
- docs/specs/plans
- shared scripts and operational guidance
- submodule pinning for exact child-repo states

### 2.2 Submodule Repositories (`program/`)
- `research-program-index`: orchestration roadmap, governance, release schema
- `benchmark-core`: benchmark contracts and baseline verification tests
- `localization-tracking`: localization and tracking domain work
- `uav-mpc-geometric-control`: UAV MPC and geometric control domain work
- `sensorless-estimation-suite`: sensorless estimation workflows
- `swarm-path-planning-bees`: swarm/path-planning workflows
- `ik-uncertainty-learning`: inverse-kinematics uncertainty workflows
- `digital-twin-pipeline`: digital twin integration pipeline
- `docs-multilingual-continuity`: documentation continuity assets
- `repro-packages`: reproducibility packaging artifacts

## 3. Quick Start (10-Minute Path)

## 4. Full Setup (First-Time Environment)

## 5. Day-2 Operations

## 6. Troubleshooting Playbooks

## 7. Contribution Workflow

## 8. Safety, Recovery, and Cleanup

## 9. References
```

- [ ] **Step 2: Run markdown sanity check by visual scan**

Run:

```bash
cd /mnt/data/ros
sed -n '1,140p' README.md
```

Expected: All section headers `## 1` through `## 9` visible in order; no old duplicate `# ROS` headings remain.

- [ ] **Step 3: Commit skeleton**

```bash
cd /mnt/data/ros
git add README.md
git commit -m "docs: scaffold comprehensive root README structure"
```

---

### Task 2: Add command-driven onboarding and setup sections

**Files:**
- Modify: `/mnt/data/ros/README.md`

- [ ] **Step 1: Fill `## 3. Quick Start (10-Minute Path)`**

Under section 3, add exactly:

```markdown
## 3. Quick Start (10-Minute Path)

Run from a clean terminal:

```bash
git clone --recurse-submodules https://github.com/molhamfetnah/ROS.git
cd ROS
git submodule sync --recursive
git submodule update --init --recursive
```

Validation checkpoint:

```bash
git submodule status
```

Expected: 10 `program/*` entries listed with commit SHAs.
```

- [ ] **Step 2: Fill `## 4. Full Setup (First-Time Environment)`**

Under section 4, add:

```markdown
## 4. Full Setup (First-Time Environment)

### 4.1 Ensure parent repo is current

```bash
cd /mnt/data/ros
git checkout main
git pull --ff-only
```

Expected: `Already up to date.` or fast-forward output.

### 4.2 Initialize submodules

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

Expected: each `program/*` submodule checked out with no errors.

### 4.3 Verify workspace health

```bash
git status --short --branch
git submodule status
```

Expected:
- parent branch shown (normally `## main`)
- no unexpected dirty state
- submodule SHAs listed

### 4.4 GitHub CLI auth (for push/PR operations)

```bash
gh auth status || gh auth login
gh repo view molhamfetnah/ROS --json defaultBranchRef
```

Expected: authenticated account and default branch details returned.
```

- [ ] **Step 3: Validate sections render correctly**

```bash
cd /mnt/data/ros
sed -n '1,260p' README.md
```

Expected: Setup sections include command blocks + expected outcomes after each block.

- [ ] **Step 4: Commit onboarding/setup**

```bash
cd /mnt/data/ros
git add README.md
git commit -m "docs: add quickstart and full setup procedures"
```

---

### Task 3: Add day-2 operations and troubleshooting playbooks

**Files:**
- Modify: `README.md` (repository root)

- [ ] **Step 1: Fill `## 5. Day-2 Operations` with operational workflows**

Add:

```markdown
## 5. Day-2 Operations

### 5.1 Sync workspace before work

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git checkout main
git pull --ff-only
git submodule sync --recursive
git submodule update --init --recursive
```

### 5.2 Worktree-based feature workflow

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git worktree add -b <feature-branch> .worktrees/<feature-branch>
cd .worktrees/<feature-branch>
```

### 5.3 Tracking-system usage (parent repo only)

After shim install, run:

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git status
ls -la .tracking
```

Expected:
- `.tracking/latest.json`
- `.tracking/history.ndjson`
- `.tracking/latest.txt`

### 5.4 Submodule-safe operations

For submodule-specific work, run commands inside target submodule:

```bash
cd <path-to-your-ROS-clone>/program/research-program-index || exit 1
git rev-parse --show-toplevel
git status
```

Parent-tracking artifacts should not be created inside submodules.
```

- [ ] **Step 2: Fill `## 6. Troubleshooting Playbooks`**

Add:

```markdown
## 6. Troubleshooting Playbooks

### Issue A: `No commits between ...` when creating PR in parent repo

Cause: work happened inside submodules, not parent tracked files.

Fix:
```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git status --short
git diff --submodule
```

If parent has no diff, create PR in the child repo instead.

### Issue B: SSH push timeout (`github.com:22`)

Fix:
```bash
gh config set git_protocol https
gh auth setup-git
git remote -v
```

Retry push after protocol switch.

### Issue C: Wrong base branch/default branch mismatch

Check:
```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
gh repo view molhamfetnah/ROS --json defaultBranchRef
gh pr view <pr-number> --repo molhamfetnah/ROS --json baseRefName,headRefName,url
```

Create PR with explicit base (safe, PR-scoped):
```bash
gh pr create --repo molhamfetnah/ROS --base main
```

Retarget an existing PR base (does not change repository default branch):
```bash
gh pr edit <pr-number> --repo molhamfetnah/ROS --base main
```

### Issue D: Submodule state drift

Fix:
```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git submodule sync --recursive
git submodule update --init --recursive
git submodule status -- program/*
```
```

- [ ] **Step 3: Validate operational/troubleshooting sections**

```bash
cd <path-to-your-ROS-clone> || exit 1
grep -n "^## 5\\|^## 6\\|^### Issue" README.md
grep -n "git submodule status -- program/\\*" README.md
! grep -n "gh repo edit .*--default-branch" README.md
```

Expected: section 5/6 headers present, scoped submodule status checks present, and no default-branch mutation command.

- [ ] **Step 4: Commit day-2 + troubleshooting**

```bash
cd <path-to-your-ROS-clone> || exit 1
git add README.md
git commit -m "docs: add day-2 operations and troubleshooting playbooks"
```

---

### Task 4: Add contribution workflow, safety, and reference map

**Files:**
- Modify: `README.md` (repository root)

- [ ] **Step 1: Fill `## 7. Contribution Workflow`**

Add:

```markdown
## 7. Contribution Workflow

### 7.1 Branching model
- Parent repo: orchestration/docs/submodule-pointer changes.
- Child repo: domain implementation changes.

### 7.2 PR sequencing
1. Merge child-repo PRs first.
2. Update/pin submodule pointers in parent.
3. Merge parent PR last.

### 7.3 Pre-PR checks

```bash
cd <path-to-your-feature-worktree> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
FEATURE_BRANCH=<your-feature-branch>
CURRENT_BRANCH="$(git branch --show-current)"
test "$CURRENT_BRANCH" != "main"
test "$CURRENT_BRANCH" = "$FEATURE_BRANCH"
git status --short --branch
git submodule status -- program/*
bash scripts/tests/test-track-git-status.sh
bash scripts/tests/test-git-tracking-shim.sh
```

Perform final parent-repo updates (submodule pointers/docs) in this same feature worktree branch only before opening the parent PR:

```bash
cd <path-to-your-feature-worktree> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
FEATURE_BRANCH=<your-feature-branch>
CURRENT_BRANCH="$(git branch --show-current)"
test "$CURRENT_BRANCH" != "main"
test "$CURRENT_BRANCH" = "$FEATURE_BRANCH"
```

Reserve the parent `main` checkout for sync/cleanup commands only (see section 8.1).

Expected: clean or intentional diff only; test scripts pass.
```

- [ ] **Step 2: Fill `## 8. Safety, Recovery, and Cleanup`**

Add:

```markdown
## 8. Safety, Recovery, and Cleanup

### 8.1 Safe cleanup

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git checkout main
git pull --ff-only
git fetch --prune
```

### 8.2 Remove finished worktree

```bash
git worktree list
git worktree remove .worktrees/<feature-branch>
```

### 8.3 Submodule recovery

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

### 8.4 DO NOT use destructive reset without explicit intent
- Avoid `git reset --hard` unless you explicitly want to discard local work.
```

- [ ] **Step 3: Fill `## 9. References`**

Add:

```markdown
## 9. References

- Design spec: `docs/superpowers/specs/2026-05-03-master-readme-guidance-design.md`
- Tracking implementation plan: `docs/superpowers/plans/2026-05-02-git-status-tracking-implementation.md`
- Repo architecture spec: `docs/superpowers/specs/2026-04-30-repo-architecture-design.md`
- Master README implementation plan: `docs/superpowers/plans/2026-05-03-master-readme-guidance-implementation.md`
- Core subrepos:
  - `program/research-program-index/README.md`
  - `program/benchmark-core/README.md`
```

- [ ] **Step 4: Validate links and section completeness**

```bash
cd <path-to-your-ROS-clone> || exit 1
for p in \
  docs/superpowers/specs/2026-05-03-master-readme-guidance-design.md \
  docs/superpowers/plans/2026-05-02-git-status-tracking-implementation.md \
  docs/superpowers/specs/2026-04-30-repo-architecture-design.md \
  docs/superpowers/plans/2026-05-03-master-readme-guidance-implementation.md \
  program/research-program-index/README.md \
  program/benchmark-core/README.md; do
  test -f "$p" || { echo "missing: $p"; exit 1; }
done
echo "reference-check: PASS"
```

Expected: `reference-check: PASS`.

- [ ] **Step 5: Commit final README rewrite**

```bash
cd <path-to-your-ROS-clone> || exit 1
git add README.md
git commit -m "docs: publish comprehensive root README operations guide"
```

---

## Spec Coverage Check (self-review)

1. **Single master README approach:** covered (Tasks 1–4 only modify root README).
2. **Onboarding + day-2 operations:** covered (Tasks 2 and 3).
3. **Command-driven with expected checkpoints:** covered throughout each task.
4. **Parent vs submodule boundaries:** covered in topology, operations, troubleshooting.
5. **Professional troubleshooting and contribution flow:** covered in Tasks 3 and 4.
6. **Reference map to deeper docs:** covered in Task 4 references section.
7. **No placeholders/TBDs:** all sections and command blocks explicitly defined.
