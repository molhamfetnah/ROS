# FI-01 Benchmark Core MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a contract-first, deterministic FI-01 benchmark MVP in `program/benchmark-core` with schema validation CLI, one localization/tracking stress scenario, and one canonical JSON artifact.

**Architecture:** Keep the repo contract-first: strict JSON schemas define inputs/outputs, a small Python validator enforces schema compliance, and a deterministic benchmark runner emits canonical JSON for a fixed-seed scenario. Acceptance is enforced with pytest through negative/positive validation tests, reproducibility exact-equality tests, and CI execution.

**Tech Stack:** Python 3.11 (stdlib + pytest), JSON schema documents, GitHub Actions CI.

---

## File Structure and Responsibilities

- **Create:** `program/benchmark-core/benchmark_core/__init__.py`  
  Package marker for FI-01 Python modules.
- **Create:** `program/benchmark-core/benchmark_core/schema_validator.py`  
  Minimal recursive validator that enforces the subset of JSON Schema used by this repo (`type`, `required`, `properties`, `items`, `enum`, `minimum`, `additionalProperties`).
- **Create:** `program/benchmark-core/benchmark_core/validate.py`  
  CLI for validating scenario/report files against their schema.
- **Create:** `program/benchmark-core/benchmark_core/run_benchmark.py`  
  Deterministic localization/tracking stress synthetic runner and canonical JSON writer.
- **Create:** `program/benchmark-core/examples/scenarios/localization_tracking_stress.json`  
  Reference FI-01 scenario input.
- **Create:** `program/benchmark-core/artifacts/expected/localization_tracking_stress.report.json`  
  Golden expected report output.
- **Modify:** `program/benchmark-core/contracts/scenario.schema.json`  
  Expand scenario contract for FI-01 required fields.
- **Modify:** `program/benchmark-core/contracts/metrics.schema.json`  
  Expand report contract with summary/provenance sections.
- **Create:** `program/benchmark-core/tests/test_schema_validator.py`  
  Unit tests for recursive validator behavior.
- **Create:** `program/benchmark-core/tests/test_validate_cli.py`  
  CLI success/failure tests.
- **Create:** `program/benchmark-core/tests/test_run_benchmark.py`  
  Determinism and golden artifact equality tests.
- **Modify:** `program/benchmark-core/tests/test_contract_files_exist.py`  
  Assert updated schema keys and constraints.
- **Create:** `program/benchmark-core/requirements-dev.txt`  
  Pin pytest for local/CI reproducibility.
- **Modify:** `program/benchmark-core/.github/workflows/ci.yml`  
  Run pytest-based quality gate.
- **Modify:** `program/benchmark-core/README.md`  
  Document FI-01 CLI usage and deterministic artifact workflow.

### Task 1: Contract Expansion (TDD)

**Files:**
- Modify: `program/benchmark-core/tests/test_contract_files_exist.py`
- Modify: `program/benchmark-core/contracts/scenario.schema.json`
- Modify: `program/benchmark-core/contracts/metrics.schema.json`

- [ ] **Step 1: Write failing schema-shape tests**

```python
def test_scenario_schema_contract_shape():
    schema = _read_schema("scenario.schema.json")
    assert schema["required"] == ["scenario_id", "task", "seed", "stress_profile", "run_config"]
    assert schema["properties"]["task"]["enum"] == ["localization_tracking"]
    assert schema["properties"]["stress_profile"]["required"] == ["dropout_rate", "drift_level"]

def test_metrics_schema_contract_shape():
    schema = _read_schema("metrics.schema.json")
    assert schema["required"] == ["scenario_id", "seed", "metrics", "summary", "provenance"]
    assert schema["properties"]["metrics"]["required"] == ["rmse", "settling_time", "max_deviation"]
    assert schema["properties"]["provenance"]["required"] == ["runner_version", "generated_at_utc"]
```

- [ ] **Step 2: Run tests to verify failure**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_contract_files_exist.py -q`  
Expected: FAIL on missing FI-01 required keys.

- [ ] **Step 3: Implement schema updates**

```json
{
  "type": "object",
  "required": ["scenario_id", "task", "seed", "stress_profile", "run_config"],
  "properties": {
    "scenario_id": { "type": "string", "minLength": 1 },
    "task": { "type": "string", "enum": ["localization_tracking"] },
    "seed": { "type": "integer" },
    "stress_profile": {
      "type": "object",
      "required": ["dropout_rate", "drift_level"],
      "properties": {
        "dropout_rate": { "type": "number", "minimum": 0.0 },
        "drift_level": { "type": "number", "minimum": 0.0 }
      },
      "additionalProperties": false
    },
    "run_config": {
      "type": "object",
      "required": ["steps", "dt"],
      "properties": {
        "steps": { "type": "integer", "minimum": 1 },
        "dt": { "type": "number", "minimum": 0.0001 }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

```json
{
  "type": "object",
  "required": ["scenario_id", "seed", "metrics", "summary", "provenance"],
  "properties": {
    "scenario_id": { "type": "string" },
    "seed": { "type": "integer" },
    "metrics": {
      "type": "object",
      "required": ["rmse", "settling_time", "max_deviation"],
      "properties": {
        "rmse": { "type": "number" },
        "settling_time": { "type": "number" },
        "max_deviation": { "type": "number" }
      },
      "additionalProperties": false
    },
    "summary": {
      "type": "object",
      "required": ["status", "samples"],
      "properties": {
        "status": { "type": "string", "enum": ["ok"] },
        "samples": { "type": "integer", "minimum": 1 }
      },
      "additionalProperties": false
    },
    "provenance": {
      "type": "object",
      "required": ["runner_version", "generated_at_utc"],
      "properties": {
        "runner_version": { "type": "string" },
        "generated_at_utc": { "type": "string" }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

- [ ] **Step 4: Run tests to verify pass**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_contract_files_exist.py -q`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
cd /mnt/data/ros/program/benchmark-core
git add contracts/scenario.schema.json contracts/metrics.schema.json tests/test_contract_files_exist.py
git commit -m "feat: expand FI-01 benchmark contracts"
```

### Task 2: Add Recursive Schema Validator + CLI (TDD)

**Files:**
- Create: `program/benchmark-core/benchmark_core/__init__.py`
- Create: `program/benchmark-core/benchmark_core/schema_validator.py`
- Create: `program/benchmark-core/benchmark_core/validate.py`
- Create: `program/benchmark-core/tests/test_schema_validator.py`
- Create: `program/benchmark-core/tests/test_validate_cli.py`

- [ ] **Step 1: Write failing validator unit tests**

```python
from benchmark_core.schema_validator import validate_document, ValidationError

def test_validate_document_accepts_valid_scenario(valid_scenario, scenario_schema):
    validate_document(valid_scenario, scenario_schema)

def test_validate_document_rejects_extra_keys(invalid_scenario_extra_key, scenario_schema):
    with pytest.raises(ValidationError, match="additional property"):
        validate_document(invalid_scenario_extra_key, scenario_schema)
```

- [ ] **Step 2: Write failing CLI tests**

```python
def test_validate_cli_passes_for_valid_scenario(tmp_path):
    result = subprocess.run(
        ["python", "-m", "benchmark_core.validate", "--kind", "scenario", "--file", str(valid_path)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    assert "VALID" in result.stdout

def test_validate_cli_fails_for_invalid_report(tmp_path):
    result = subprocess.run(
        ["python", "-m", "benchmark_core.validate", "--kind", "report", "--file", str(invalid_path)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 1
    assert "INVALID" in result.stderr
```

- [ ] **Step 3: Run tests to verify failure**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_schema_validator.py tests/test_validate_cli.py -q`  
Expected: FAIL with `ModuleNotFoundError: No module named 'benchmark_core'`.

- [ ] **Step 4: Implement minimal validator + CLI**

```python
# benchmark_core/schema_validator.py
class ValidationError(ValueError):
    pass

def validate_document(document: object, schema: dict) -> None:
    _validate_node(document, schema, "$")
```

```python
# benchmark_core/validate.py
if __name__ == "__main__":
    # parse --kind and --file
    # load corresponding schema from contracts/
    # validate JSON file, print VALID on success, INVALID on failure
    # exit 0/1
```

- [ ] **Step 5: Run tests to verify pass**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_schema_validator.py tests/test_validate_cli.py -q`  
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
cd /mnt/data/ros/program/benchmark-core
git add benchmark_core tests/test_schema_validator.py tests/test_validate_cli.py
git commit -m "feat: add FI-01 schema validator and validation CLI"
```

### Task 3: Add Scenario + Deterministic Runner + Golden Artifact (TDD)

**Files:**
- Create: `program/benchmark-core/examples/scenarios/localization_tracking_stress.json`
- Create: `program/benchmark-core/benchmark_core/run_benchmark.py`
- Create: `program/benchmark-core/tests/test_run_benchmark.py`
- Create: `program/benchmark-core/artifacts/expected/localization_tracking_stress.report.json`

- [ ] **Step 1: Write failing runner tests**

```python
def test_runner_produces_schema_valid_report(tmp_path):
    output = tmp_path / "report.json"
    result = subprocess.run(
        ["python", "-m", "benchmark_core.run_benchmark", "--scenario", str(SCENARIO), "--output", str(output)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    validate_document(json.loads(output.read_text()), metrics_schema())

def test_runner_is_deterministic(tmp_path):
    out1 = tmp_path / "a.json"
    out2 = tmp_path / "b.json"
    run_cli(out1)
    run_cli(out2)
    assert json.loads(out1.read_text()) == json.loads(out2.read_text())
```

- [ ] **Step 2: Run tests to verify failure**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_run_benchmark.py -q`  
Expected: FAIL because runner module and fixtures do not exist yet.

- [ ] **Step 3: Add scenario and runner implementation**

```json
{
  "scenario_id": "localization_tracking_stress_v1",
  "task": "localization_tracking",
  "seed": 42,
  "stress_profile": { "dropout_rate": 0.1, "drift_level": 0.03 },
  "run_config": { "steps": 120, "dt": 0.1 }
}
```

```python
# benchmark_core/run_benchmark.py
# 1) validate scenario against scenario.schema.json
# 2) compute deterministic synthetic metrics from seed + scenario params
# 3) emit canonical JSON (sort_keys=True, indent=2, trailing newline)
# 4) validate report against metrics.schema.json
```

- [ ] **Step 4: Generate and commit golden artifact**

Run:

```bash
cd /mnt/data/ros/program/benchmark-core
python -m benchmark_core.run_benchmark \
  --scenario examples/scenarios/localization_tracking_stress.json \
  --output artifacts/expected/localization_tracking_stress.report.json
```

Expected: file created with stable JSON content.

- [ ] **Step 5: Add golden equality test and verify pass**

```python
def test_runner_matches_golden_artifact(tmp_path):
    generated = tmp_path / "generated.json"
    run_cli(generated)
    golden = json.loads(Path("artifacts/expected/localization_tracking_stress.report.json").read_text())
    assert json.loads(generated.read_text()) == golden
```

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_run_benchmark.py -q`  
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
cd /mnt/data/ros/program/benchmark-core
git add examples/scenarios/localization_tracking_stress.json benchmark_core/run_benchmark.py tests/test_run_benchmark.py artifacts/expected/localization_tracking_stress.report.json
git commit -m "feat: add deterministic FI-01 benchmark runner and golden artifact"
```

### Task 4: Wire Dependencies and CI Gate (TDD)

**Files:**
- Create: `program/benchmark-core/requirements-dev.txt`
- Modify: `program/benchmark-core/.github/workflows/ci.yml`

- [ ] **Step 1: Write failing CI expectation test**

Add test:

```python
def test_ci_runs_pytest():
    ci = Path(".github/workflows/ci.yml").read_text()
    assert "pytest -q" in ci
```

Place in `tests/test_ci_contract.py`.

- [ ] **Step 2: Run test to verify failure**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_ci_contract.py -q`  
Expected: FAIL (current CI only echoes baseline message).

- [ ] **Step 3: Implement CI + dev requirements**

`requirements-dev.txt`:

```txt
pytest==8.3.2
```

`ci.yml` job steps should include:

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: "3.11"
- run: python -m pip install --upgrade pip
- run: pip install -r requirements-dev.txt
- run: pytest -q
```

- [ ] **Step 4: Run test to verify pass**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_ci_contract.py -q`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
cd /mnt/data/ros/program/benchmark-core
git add requirements-dev.txt .github/workflows/ci.yml tests/test_ci_contract.py
git commit -m "ci: run benchmark-core pytest quality gate"
```

### Task 5: Document FI-01 Workflow and Run Full Verification

**Files:**
- Modify: `program/benchmark-core/README.md`

- [ ] **Step 1: Write failing README expectation test**

Add test:

```python
def test_readme_documents_fi01_commands():
    readme = Path("README.md").read_text(encoding="utf-8")
    assert "python -m benchmark_core.validate --kind scenario" in readme
    assert "python -m benchmark_core.run_benchmark" in readme
```

Place in `tests/test_readme_contract.py`.

- [ ] **Step 2: Run test to verify failure**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest tests/test_readme_contract.py -q`  
Expected: FAIL (README does not include FI-01 command workflow).

- [ ] **Step 3: Update README with exact commands**

README section must include:

```bash
cd /mnt/data/ros/program/benchmark-core
python -m pip install -r requirements-dev.txt
python -m benchmark_core.validate --kind scenario --file examples/scenarios/localization_tracking_stress.json
python -m benchmark_core.run_benchmark --scenario examples/scenarios/localization_tracking_stress.json --output /tmp/fi01-report.json
python -m benchmark_core.validate --kind report --file /tmp/fi01-report.json
```

- [ ] **Step 4: Run full suite**

Run: `cd /mnt/data/ros/program/benchmark-core && pytest -q`  
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
cd /mnt/data/ros/program/benchmark-core
git add README.md tests/test_readme_contract.py
git commit -m "docs: add FI-01 benchmark-core runbook and verification commands"
```

## Final Verification Checklist

- [ ] `cd /mnt/data/ros/program/benchmark-core && pytest -q` passes locally.
- [ ] Running benchmark command twice with same scenario yields exact same JSON.
- [ ] Generated report matches `artifacts/expected/localization_tracking_stress.report.json`.
- [ ] CI workflow runs pytest on push/PR.

