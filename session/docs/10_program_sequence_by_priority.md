# Program Sequence Plan — All Candidates by Priority Matrix

This plan extends beyond a single paper and sequences **all FI candidates** from the evaluation matrix and ranked roadmap.

## Priority order (master sequence)
1. FI-01 Reproducible benchmark suite  
2. FI-02 Unified evaluation protocol  
3. FI-03 Stress-test framework  
4. FI-12 Replication package (one-command reproduce)  
5. FI-06 UKF/EKF/Particle-filter localization ablation  
6. FI-07 Nonlinear MPC + geometric control baseline  
7. FI-05 MRAS/SMO/EKF sensorless estimator comparison  
8. FI-04 Open simulation stack unification  
9. FI-08 Modernized Bees Algorithm for dynamic planning  
10. FI-09 Learning-augmented IK with uncertainty  
11. FI-10 Digital twin pipeline  
12. FI-11 Multi-language continuity package

---

## Wave-by-wave execution (sequential)

## Wave 1 — Foundation and trust (FI-01, FI-02, FI-03, FI-12)
**Goal:** establish publishable rigor and reproducibility baseline.

1. Build benchmark harness and scenario catalog.
2. Lock metric definitions and evaluation scripts.
3. Add mandatory stress and edge-case suites.
4. Ship replication package with one-command runs.

**Output gate to pass before Wave 2:**
- reproducible results on two pipelines,
- benchmark tables regenerated from raw data,
- automated stress report.

## Wave 2 — Core simulation paper lane (FI-06, FI-07)
**Goal:** deliver strongest simulation-only paper track.

1. EKF/UKF/Particle-filter ablation under unified protocol.
2. MPC + geometric baseline comparison for tracking.
3. Cross-pipeline parity (ROS/Gazebo and Simulink).

**Output gate to pass before Wave 3:**
- ArXiv-ready manuscript draft,
- release-grade repository with reproducibility docs.

## Wave 3 — Sensorless and control depth (FI-05, FI-04)
**Goal:** expand technical depth in control/estimation.

1. Implement MRAS/SMO/EKF comparison in simulation model stack.
2. Unify and standardize open simulation stack architecture.

**Output gate to pass before Wave 4:**
- reusable module architecture,
- sensitivity and failure-mode analysis package.

## Wave 4 — Optimization and ML extension (FI-08, FI-09)
**Goal:** add novelty via planning + learning integration.

1. Upgrade Bees Algorithm for dynamic constrained environments.
2. Add learning-augmented IK with uncertainty quantification.

**Output gate to pass before Wave 5:**
- comparative studies vs classical baselines,
- transparent risk and limitation statements.

## Wave 5 — Long-horizon impact (FI-10, FI-11)
**Goal:** maximize professional and academic visibility.

1. Build digital twin pipeline (simulation-first with future hardware bridge).
2. Publish multi-language continuity package for broader reach.

**Output gate (program completion):**
- mature portfolio repository,
- multiple publishable manuscripts/extensions,
- clear scholarship-ready narrative.

---

## Dependency and transition map
1. FI-01 → prerequisite for FI-02, FI-03, FI-12.
2. FI-02/FI-03/FI-12 → prerequisite quality gate for FI-06/FI-07.
3. FI-06/FI-07 → establishes benchmark backbone for FI-05/FI-08/FI-09.
4. FI-04 supports FI-05 through FI-10 by enforcing shared architecture.
5. FI-11 is parallelizable late-stage documentation layer.

---

## Professional cadence per candidate
For each FI candidate:
1. Problem statement and success metrics.
2. Simulation implementation in both pipelines.
3. Stress tests + edge-case report.
4. Reproducibility package and docs update.
5. Paper section draft + repo release note.

---

## Current position in sequence
You are currently in **Wave 2 (FI-06 focus)** through the locked benchmark topic:
**EKF/UKF localization + trajectory tracking (simulation-only, dual pipeline).**
