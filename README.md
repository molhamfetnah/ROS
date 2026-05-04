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

Run from a clean terminal:

```bash
git clone --recurse-submodules https://github.com/molhamfetnah/ROS.git
cd ROS
git submodule sync --recursive
git submodule update --init --recursive
```

Validation checkpoint:

```bash
git submodule status -- program/*
```

Expected: 10 `program/*` entries listed with commit SHAs.

## 4. Full Setup (First-Time Environment)

### 4.1 Ensure parent repo is current

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git checkout main
git pull --ff-only
```

Expected:
- `git rev-parse --show-toplevel` prints the absolute path to your clone root.
- Worktree and exact canonical `origin` identity checks pass before branch mutation commands run.
- `Already up to date.` or fast-forward output.

### 4.2 Initialize submodules

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

Expected: each `program/*` submodule checked out with no errors.

### 4.3 Verify workspace health

```bash
git status --short --branch
git submodule status -- program/*
```

Expected:
- parent branch shown (normally `## main`)
- no unexpected dirty state
- 10 `program/*` submodule SHAs listed

### 4.4 GitHub CLI auth (for push/PR operations)

```bash
gh auth status || gh auth login
gh repo view molhamfetnah/ROS --json defaultBranchRef
```

Expected: authenticated account and default branch details returned.

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
git checkout main || exit 1
git pull --ff-only || exit 1
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

## 7. Contribution Workflow

### 7.1 Branching model
- Parent repo: orchestration/docs/submodule-pointer changes.
- Child repo: domain implementation changes.

### 7.2 PR sequencing
1. Merge child-repo PRs first.
2. Update/pin submodule pointers in parent.
3. Merge parent PR last.

### 7.3 Pre-PR checks

Run these checks from the feature worktree that contains your PR changes (not the parent `main` checkout):

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

## 8. Safety, Recovery, and Cleanup

### 8.1 Safe cleanup

Run cleanup/sync commands from the parent `main` checkout, not from an active feature worktree:

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
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git worktree list
git worktree remove .worktrees/<feature-branch>
```

### 8.3 Submodule recovery

```bash
cd <path-to-your-ROS-clone> || exit 1
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree >/dev/null
origin_url="$(git remote get-url origin 2>/dev/null || true)"
printf '%s\n' "$origin_url" | grep -Eq '^(git@github\.com:molhamfetnah/ROS(\.git)?|https://github\.com/molhamfetnah/ROS(\.git)?)$' || { echo "Error: origin must be molhamfetnah/ROS (SSH or HTTPS)." >&2; exit 1; }
git submodule sync --recursive
git submodule update --init --recursive
```

### 8.4 DO NOT use destructive reset without explicit intent
- Avoid `git reset --hard` unless you explicitly want to discard local work.

## 9. References

- Design spec: `docs/superpowers/specs/2026-05-03-master-readme-guidance-design.md`
- Tracking implementation plan: `docs/superpowers/plans/2026-05-02-git-status-tracking-implementation.md`
- Repo architecture spec: `docs/superpowers/specs/2026-04-30-repo-architecture-design.md`
- Master README implementation plan: `docs/superpowers/plans/2026-05-03-master-readme-guidance-implementation.md`
- Core subrepos:
  - `program/research-program-index/README.md`
  - `program/benchmark-core/README.md`
