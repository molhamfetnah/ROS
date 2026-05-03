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
git submodule status
```

Expected: 10 `program/*` entries listed with commit SHAs.

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

## 5. Day-2 Operations

## 6. Troubleshooting Playbooks

## 7. Contribution Workflow

## 8. Safety, Recovery, and Cleanup

## 9. References
