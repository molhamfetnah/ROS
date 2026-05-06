# Appendix A — Dual Pipeline Blueprint (Simulation-Only)

## A1. Python/ROS2/Gazebo/Jupyter pipeline
1. Scenario definitions (YAML): trajectories, disturbances, sensor models.
2. ROS2 nodes:
   - estimator node (EKF/UKF)
   - controller node (baseline + advanced)
   - logger node (metrics, state traces)
3. Gazebo world variants:
   - nominal
   - noisy sensors
   - disturbances and delays
4. Jupyter notebooks:
   - statistical comparison
   - ablation charts
   - reproducibility report generation

## A2. MATLAB/Simulink pipeline
1. Simulink plant + sensor model mirroring ROS/Gazebo assumptions.
2. Controller subsystem variants:
   - baseline
   - candidate improved controller
3. Automated simulation scripts:
   - batch runs
   - seed control
   - metric export to CSV

## A3. Cross-pipeline parity constraints
1. Shared scenario catalog IDs.
2. Shared random seed schedule.
3. Shared metric formulas.
4. Shared run budget per scenario.
5. Shared report format for direct side-by-side tables.

## A4. Acceptance thresholds (minimum)
1. No regression vs baseline in nominal scenario.
2. Measured gain in at least 2 stress conditions.
3. Stable behavior under initialization perturbations.
