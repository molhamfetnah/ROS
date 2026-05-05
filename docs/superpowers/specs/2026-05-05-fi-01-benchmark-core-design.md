# FI-01 Benchmark Core MVP Design (Contract-First)

## 1. Problem and Goal

FI-01 needs a reproducible, contract-first benchmark foundation in `benchmark-core` so downstream wave-1 projects can consume stable scenario and metrics interfaces. The MVP goal is to deliver a deterministic localization/tracking stress-test flow that validates inputs and outputs against strict schemas and produces one canonical JSON artifact.

## 2. Scope

### In Scope

- Finalize scenario and metrics JSON schemas for FI-01 MVP.
- Add a Python validator CLI for scenario/report contract validation.
- Add a deterministic Python benchmark runner (fixed-seed synthetic localization/tracking stress simulation stub).
- Add one reference scenario and one canonical expected JSON report artifact.
- Add pytest coverage for schema validity, CLI behavior, determinism, and golden artifact equality.

### Out of Scope

- Multi-scenario orchestration.
- Real robotics middleware integration (ROS2 runtime execution).
- Advanced visualization/report dashboards.
- Cross-repo integration work beyond publishing stable benchmark-core contracts/artifacts.

## 3. Architecture

FI-01 MVP uses four layers:

1. **Contracts layer**: strict JSON schemas define acceptable scenario inputs and benchmark report outputs.
2. **Validation layer**: Python CLI validates scenario and report files against contracts and fails with explicit errors.
3. **Execution layer**: deterministic runner reads a validated scenario and emits a canonical benchmark JSON report.
4. **Quality gate layer**: tests enforce repeatability and exact equality against a committed expected artifact.

This architecture minimizes early implementation risk while maximizing reproducibility and interface stability.

## 4. Components and File Layout

Target repository: `program/benchmark-core`

- `contracts/scenario.schema.json`
  - Canonical scenario contract for FI-01 localization/tracking stress runs.
  - Includes required fixed seed, stress profile, and run metadata.
- `contracts/metrics.schema.json`
  - Canonical benchmark report contract.
  - Includes required metric fields, summary section, and provenance metadata.
- `benchmark_core/validate.py`
  - CLI entry to validate scenario/report files against the corresponding schema.
  - Non-zero exit on any contract error.
- `benchmark_core/run_benchmark.py`
  - Deterministic fixed-seed synthetic benchmark runner for localization/tracking stress-test.
  - Emits canonical JSON report.
- `examples/scenarios/localization_tracking_stress.json`
  - Single approved MVP scenario.
- `artifacts/expected/localization_tracking_stress.report.json`
  - Golden expected benchmark output for reproducibility gating.
- `tests/`
  - Positive and negative schema validation tests.
  - Deterministic rerun tests.
  - Golden artifact exact-equality tests.

## 5. Data Flow

1. User invokes benchmark runner with a scenario JSON file.
2. Scenario is validated against `scenario.schema.json`.
3. Runner executes deterministic synthetic localization/tracking stress logic with required fixed seed.
4. Report JSON is generated.
5. Report is validated against `metrics.schema.json`.
6. Reproducibility tests compare produced output to the committed golden artifact using exact JSON equality.

## 6. Error Handling Policy

- Validation errors are explicit and include file path and failing field/constraint.
- Invalid input is a hard failure; no silent fallback behavior is allowed.
- Output contract violations are hard failures and block completion.
- CLI commands return non-zero on any validation or run failure.

## 7. Reproducibility Rules

- Scenario contract requires a fixed seed field.
- Runner behavior is deterministic for identical input.
- Output JSON is canonicalized to keep key ordering and structure stable.
- FI-01 acceptance requires exact equality between repeated outputs and the golden artifact.

## 8. Testing Strategy

Pytest-based coverage includes:

1. Contract file existence and structural validity tests.
2. Positive validation tests for valid scenario/report files.
3. Negative validation tests for malformed/invalid files.
4. Deterministic runner tests: identical input run twice yields identical JSON.
5. Golden artifact tests: generated report equals committed expected report exactly.

CI must run the FI-01 test suite and fail on any reproducibility or contract regression.

## 9. Acceptance Criteria

FI-01 MVP is complete when:

1. `benchmark-core` contains finalized FI-01 scenario and metrics schemas.
2. Python validator CLI validates scenarios/reports and fails correctly on invalid data.
3. One localization/tracking stress scenario runs deterministically with fixed seed.
4. The benchmark runner emits a canonical JSON report.
5. Generated output matches committed expected artifact exactly.
6. All FI-01 tests pass in CI.

## 10. Risks and Mitigations

- **Risk:** Schema churn during downstream adoption.
  - **Mitigation:** Keep MVP schema minimal but strict, and version schema changes explicitly after FI-01.
- **Risk:** Hidden nondeterminism breaks reproducibility gate.
  - **Mitigation:** Fixed seed requirement + deterministic runner logic + exact-equality tests.
- **Risk:** Over-expanding MVP scope.
  - **Mitigation:** Restrict to one scenario and one canonical artifact in FI-01.
