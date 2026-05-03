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
