# Master Dossier (Refined, Interactive-Driven)

## 1. Locked decisions from your interactive responses
1. Primary goal is **both**: maximum paper readiness + professional GitHub repository.
2. Scope is **simulation/modeling only** (no lab dependency).
3. Delivery requires **two full parallel pipelines**:
   - Python + ROS2/Gazebo + Jupyter
   - MATLAB/Simulink
4. Publication strategy is **ArXiv preprint + code release first**.
5. Documentation format is **one master dossier + appendices**.

## 2. Current evidence base and clustered corpus
Using clustered data under `session/artifacts_clustered`:
- Own cluster:
  - papers: **53**
  - downloaded PDFs: **3**
- Related cluster:
  - papers: **198**
  - downloaded PDFs: **91**
  - failed retrievals: **107**

This is enough to proceed with a simulation-first publishable workflow while maintaining traceability of unresolved full-text items.

## 3. Research objective for current cycle (Cycle-1)
Build a simulation-first reproducible contribution that:
1. Extends one of Joukhadar-aligned control/robotics themes.
2. Benchmarks against strong baselines on shared metrics.
3. Ships with open code, reproducible scripts, and stress tests.
4. Produces an ArXiv-ready manuscript plus a professional repository release.

### Locked preprint problem statement
**“A dual-pipeline simulation benchmark for EKF/UKF localization and trajectory tracking under stress conditions.”**

Target contribution:
1. Fair EKF vs UKF comparison under matched simulation scenarios.
2. Cross-validation of results in ROS2/Gazebo and MATLAB/Simulink.
3. Stress-profile robustness analysis (noise, delay, dropout, mismatch).
4. Reproducible open benchmark package + ArXiv manuscript.

## 4. Priority research lane (simulation-only, publishable fast)
Primary lane for fastest publishability without lab access:
1. **Localization + tracking benchmark lane**
   - UKF/EKF localization baseline
   - UAV/robot trajectory tracking baseline
   - stress tests under noise/disturbance/model mismatch
2. Secondary lane after baseline stability:
   - advanced controller variant (e.g., MPC or robust/adaptive variant)
   - ablation and sensitivity analysis

## 5. Detailed execution plan (step-by-step)
### Phase A — Corpus normalization and claim extraction
1. Use only cluster files for traceable references:
   - `own/datasets/raw/cluster_own_papers.csv`
   - `related/datasets/raw/cluster_related_papers.csv`
2. Build a claim table per selected paper:
   - problem, method, assumptions, metrics, limitations.
3. Build an evidence matrix:
   - which claims are reproducible in pure simulation.

### Phase B — Dual pipeline implementation (parallel)
1. Implement identical experiment protocol in both stacks:
   - Python/ROS2/Gazebo/Jupyter
   - MATLAB/Simulink
2. Keep same scenario IDs, same seeds, same metrics definitions.
3. Add synchronization rules:
   - same initial conditions
   - same disturbance schedule
   - same evaluation windows

### Phase C — Evaluation and stress framework
1. Core metrics:
   - RMSE (state/trajectory)
   - settling time
   - overshoot
   - control energy
   - robustness success rate
2. Stress suite:
   - sensor noise ladder
   - dropouts
   - actuator saturation
   - delayed measurements
   - model mismatch
3. Edge-case suite:
   - poor initialization
   - abrupt trajectory changes
   - out-of-distribution disturbance profiles

### Phase C.1 — Minimum benchmark scenario set (mandatory)
1. **Nominal tracking**: no disturbance, baseline comparison.
2. **Moderate sensor noise**: Gaussian noise ladder.
3. **High sensor noise**: failure boundary mapping.
4. **Measurement delay**: 50/100/200 ms.
5. **Dropout windows**: periodic and burst dropout.
6. **Model mismatch**: parameter perturbation + unmodeled dynamics.

### Phase D — Reproducibility and release engineering
1. One-command experiment runners for each stack.
2. Locked dependency manifests.
3. Artifact outputs:
   - raw results
   - processed tables/plots
   - run metadata and seeds
4. Release bundle:
   - repo tag + changelog
   - reproducibility guide
   - benchmark summary sheet

### Phase E — ArXiv-first writing workflow
1. Draft structure:
   - problem framing from Joukhadar-aligned gap
   - method (dual-pipeline protocol)
   - experiments (fair benchmark + stress)
   - limits + threat model + reproducibility
2. Add repo link and reproducibility badge in paper.
3. Publish preprint and repository together.

## 6. Professional output package checklist
1. Public repository with clear architecture and tests.
2. ArXiv manuscript with transparent methodology.
3. Dataset/artifact linkage table between paper figures and raw outputs.
4. Explicit limitations and future work section (not hype-only claims).

## 7. File map for this refined set
1. Main dossier: `06_master_dossier.md`
2. Appendix A: `07_appendix_a_dual_pipeline_blueprint.md`
3. Appendix B: `08_appendix_b_arxiv_repo_release_protocol.md`
4. Appendix C: `09_appendix_c_experiment_matrix_and_templates.md`
5. Program sequence plan (all candidates): `10_program_sequence_by_priority.md`

## 8. Multi-cycle continuity (not locked to one study)
This dossier now operates as **Cycle-1** of a larger research program.  
Full sequence across all candidate improvements is defined in:
`10_program_sequence_by_priority.md`

Execution rule:
1. Finish current cycle deliverables (ArXiv + repo for EKF/UKF benchmark).
2. Continue directly to the next candidate wave by priority.
3. Preserve one reproducibility standard across all cycles.
