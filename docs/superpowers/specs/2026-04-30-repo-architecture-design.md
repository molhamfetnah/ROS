# Repository Architecture Design — Multi-Repo Research Program

## Context
This design defines a clean, scalable repository architecture for a large simulation-first research program that must execute all priority candidates sequentially while keeping publication and engineering quality high.

User-approved constraints:
1. Primary goal: maximize paper readiness and professional GitHub quality.
2. No current lab access: simulation/modeling only.
3. Two full pipelines in parallel: Python/ROS2/Gazebo/Jupyter and MATLAB/Simulink.
4. Publication mode: ArXiv preprint + code release first.
5. Repo strategy: **multiple independent repos with one meta-index repo**.
6. Visibility: public by default, private only for drafts.
7. Roadmap model: hybrid (central roadmap + local technical issues).
8. Final chosen architecture option: **Option A — domain-based multi-repo**.

## Proposed Architecture (Approved)

## 1. Topology
1. `research-program-index` (meta-repo):
   - global roadmap and priority matrix,
   - cross-repo milestones and release board,
   - architecture and contribution standards,
   - quality gate definitions and CI rollup status,
   - links to all sub-repos and published artifacts.

2. Domain repos:
   - `benchmark-core`
   - `localization-tracking`
   - `uav-mpc-geometric-control`
   - `sensorless-estimation-suite`
   - `swarm-path-planning-bees`
   - `ik-uncertainty-learning`
   - `digital-twin-pipeline`
   - `docs-multilingual-continuity`

3. Optional packaging repo:
   - `repro-packages` for release-grade reproducibility bundles and manifests.

## 2. Data and Artifact Flow
1. `benchmark-core` owns canonical scenario schema and metric contracts.
2. Domain repos implement methods and emit standardized result artifacts.
3. `research-program-index` indexes run manifests (scenario IDs, seeds, repo SHAs, artifact pointers, paper figure mapping).
4. Papers and reports reference exact commit SHAs and manifest IDs.

Storage policy:
1. Code in domain repos.
2. Large artifacts via release assets/LFS-compatible storage.
3. Lightweight manifest pointers in git.
4. Local workspace mirrors (e.g., `artifacts_clustered`) are treated as working mirrors; publishable subsets are promoted by manifest.

## 3. Quality, CI/CD, and Failure Model
Per-domain-repo CI:
1. lint and static checks,
2. deterministic seed runs,
3. stress-test smoke suite,
4. artifact schema validation.

Cross-repo CI in `research-program-index`:
1. nightly integration against pinned SHAs,
2. compatibility checks for scenario/metric contracts.

Quality gates required for progression:
1. reproducibility gate (clean rerun success),
2. metrics gate (canonical benchmark/stress outputs),
3. documentation gate (assumptions, limits, method updates).

Failure handling:
1. failed quality gate blocks merge to `main`,
2. local issue in owning repo + central incident issue for cross-repo breakage.

## 4. Sequential Program Execution (All Candidates)
Execution strictly follows priority sequence:
1. FI-01, FI-02, FI-03, FI-12 (foundation)
2. FI-06, FI-07 (core simulation paper lane)
3. FI-05 (sensorless estimator depth)
4. FI-08, FI-09 (planning + ML extension)
5. FI-10, FI-11 (long-horizon maturity and visibility)

Promotion rule:
1. each step must pass quality gates,
2. each completed step produces a tagged reproducibility release,
3. next candidate begins only after previous step release evidence is published.

## 5. Repository Ownership and Issue Model
1. Central roadmap, governance, and sequencing in `research-program-index`.
2. Technical execution issues remain inside each domain repo.
3. Cross-cutting blockers are mirrored to central incidents in `research-program-index`.

## 6. Risks and Mitigations
1. **Risk:** repo fragmentation and drift.  
   **Mitigation:** contract-first design in `benchmark-core` + nightly cross-repo validation.
2. **Risk:** reproducibility inconsistency across pipelines.  
   **Mitigation:** shared scenario IDs, seed schedules, metric formulas, and manifest schema.
3. **Risk:** release overhead across many repos.  
   **Mitigation:** standardized release templates and central orchestration in meta-repo.

## 7. Acceptance Criteria
Design is successful when:
1. repo topology supports all priority candidates without structural changes,
2. every candidate can be executed and released with traceable artifacts,
3. ArXiv + repository releases can be produced with exact commit and artifact linkage.
