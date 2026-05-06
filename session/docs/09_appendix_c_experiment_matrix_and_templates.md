# Appendix C — Experiment Matrix and Writing Templates

## C1. Experiment matrix template
| Scenario ID | Pipeline | Controller | Estimator | Disturbance | Seed | RMSE | Settling | Control Energy | Pass/Fail |
|---|---|---|---|---|---|---:|---:|---:|---|
| S001 | ROS/Gazebo | Baseline | EKF | Nominal | 42 |  |  |  |  |
| S001 | Simulink | Baseline | EKF | Nominal | 42 |  |  |  |  |

## C1.1 Required scenarios for current preprint
| Scenario ID | Description | Disturbance Profile | Must compare EKF vs UKF |
|---|---|---|---|
| S001 | Nominal tracking | none | yes |
| S002 | Moderate noise | Gaussian low/medium | yes |
| S003 | High noise | Gaussian high | yes |
| S004 | Delay robustness | 50/100/200 ms delay | yes |
| S005 | Sensor dropout | burst + periodic | yes |
| S006 | Model mismatch | parameter perturbation | yes |

## C2. Stress-test matrix template
| Stress Case | Level | Expected Failure Mode | Mitigation | Observed Behavior | Outcome |
|---|---|---|---|---|---|
| Sensor noise | high | estimator drift | adaptive covariance |  |  |
| Delay | 200ms | oscillation | prediction compensation |  |  |

## C3. Paper-ready result narrative template
1. **Claim:** what improves and under which conditions.
2. **Evidence:** exact metric deltas and scenario IDs.
3. **Counter-case:** where method does not improve.
4. **Interpretation:** why behavior changes under stress.
5. **Limitations:** assumptions and transfer risks.

## C4. Professional academic reaction template
“Building on Joukhadar-aligned prior work in control and robotics, this study contributes a simulation-only, dual-pipeline reproducibility protocol (ROS/Gazebo and Simulink) that enables fair cross-method comparison under nominal and stress conditions. The released repository includes complete experiment scripts, metric definitions, and edge-case evaluations, supporting transparent verification and extension.”
