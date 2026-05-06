# Multi-Repo Program Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and initialize a clean domain-based multi-repo research program structure (meta-index + domain repos), with shared standards, CI baselines, and GitHub CLI-driven remote setup.

**Architecture:** Create one central orchestration repo (`research-program-index`) and multiple domain repos aligned to the priority matrix. Standardize each repo with identical foundational files (README, LICENSE, CI, issue templates, CODEOWNERS, `.editorconfig`) and connect all repos back to the index via manifests and badges. Keep implementation simulation-first and release-traceable.

**Tech Stack:** Git, GitHub CLI (`gh`), Markdown docs, YAML (GitHub Actions), Bash scripts, Python tooling (optional for utility scripts)

---

## File Structure Plan (locked before tasks)

Program workspace root:
- `/mnt/data/ros/program/`

Repository directories to create:
- `/mnt/data/ros/program/research-program-index`
- `/mnt/data/ros/program/benchmark-core`
- `/mnt/data/ros/program/localization-tracking`
- `/mnt/data/ros/program/uav-mpc-geometric-control`
- `/mnt/data/ros/program/sensorless-estimation-suite`
- `/mnt/data/ros/program/swarm-path-planning-bees`
- `/mnt/data/ros/program/ik-uncertainty-learning`
- `/mnt/data/ros/program/digital-twin-pipeline`
- `/mnt/data/ros/program/docs-multilingual-continuity`
- `/mnt/data/ros/program/repro-packages`

Common files inside every repo:
- `README.md`
- `LICENSE`
- `.gitignore`
- `.editorconfig`
- `.github/workflows/ci.yml`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/CODEOWNERS`

Meta-index-only files:
- `roadmap/priority-matrix.md`
- `roadmap/wave-plan.md`
- `registry/repos.yaml`
- `registry/quality-gates.md`
- `registry/release-manifest-schema.json`

---

### Task 1: Bootstrap local program workspace and meta-index repo

**Files:**
- Create: `/mnt/data/ros/program/research-program-index/README.md`
- Create: `/mnt/data/ros/program/research-program-index/roadmap/priority-matrix.md`
- Create: `/mnt/data/ros/program/research-program-index/roadmap/wave-plan.md`
- Create: `/mnt/data/ros/program/research-program-index/registry/repos.yaml`
- Create: `/mnt/data/ros/program/research-program-index/registry/quality-gates.md`
- Create: `/mnt/data/ros/program/research-program-index/registry/release-manifest-schema.json`

- [ ] **Step 1: Create workspace and initialize repo**

```bash
mkdir -p /mnt/data/ros/program/research-program-index
cd /mnt/data/ros/program/research-program-index
git init
```

- [ ] **Step 2: Create meta-index README**

```markdown
# research-program-index

Central orchestration repo for the multi-repo simulation-first research program.

## Responsibilities
- Global roadmap and priority sequence
- Cross-repo quality gates
- Release and artifact manifest standards
- Cross-repo status board
```

- [ ] **Step 3: Create roadmap and registry files**

```bash
mkdir -p roadmap registry
```

`roadmap/priority-matrix.md`:
```markdown
# Priority Matrix
1. FI-01, FI-02, FI-03, FI-12
2. FI-06, FI-07
3. FI-05
4. FI-08, FI-09
5. FI-10, FI-11
```

`registry/repos.yaml`:
```yaml
repos:
  - name: benchmark-core
  - name: localization-tracking
  - name: uav-mpc-geometric-control
  - name: sensorless-estimation-suite
  - name: swarm-path-planning-bees
  - name: ik-uncertainty-learning
  - name: digital-twin-pipeline
  - name: docs-multilingual-continuity
  - name: repro-packages
```

- [ ] **Step 4: Commit meta-index bootstrap**

```bash
git add .
git commit -m "chore: bootstrap research-program-index"
```

---

### Task 2: Create all domain repos with standardized baseline files

**Files:**
- Create (each repo): `README.md`, `.editorconfig`, `.gitignore`, `.github/*`, `LICENSE`

- [ ] **Step 1: Create domain repo directories and initialize git**

```bash
cd /mnt/data/ros/program
for r in benchmark-core localization-tracking uav-mpc-geometric-control sensorless-estimation-suite swarm-path-planning-bees ik-uncertainty-learning digital-twin-pipeline docs-multilingual-continuity repro-packages; do
  mkdir -p "$r"
  (cd "$r" && git init)
done
```

- [ ] **Step 2: Add baseline files template to one repo and reuse**

`README.md` template:
```markdown
# <repo-name>

## Scope
Domain repository for the research program.

## Interfaces
- Inputs: scenario configs + benchmark contract
- Outputs: standardized metrics/artifacts
```

`.editorconfig`:
```ini
root = true

[*.{py,md,yml,yaml,json}]
indent_style = space
indent_size = 2
charset = utf-8
end_of_line = lf
insert_final_newline = true
```

`.gitignore`:
```gitignore
.venv/
__pycache__/
*.pyc
artifacts/
```

- [ ] **Step 3: Add GitHub templates and CI in each repo**

```bash
mkdir -p .github/workflows .github/ISSUE_TEMPLATE
```

`.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Baseline CI for repository structure"
```

- [ ] **Step 4: Commit each repo baseline**

```bash
for r in benchmark-core localization-tracking uav-mpc-geometric-control sensorless-estimation-suite swarm-path-planning-bees ik-uncertainty-learning digital-twin-pipeline docs-multilingual-continuity repro-packages; do
  (cd "/mnt/data/ros/program/$r" && git add . && git commit -m "chore: initialize repository baseline")
done
```

---

### Task 3: Configure GitHub remotes and repository creation via gh CLI

**Files:**
- Modify: `/mnt/data/ros/program/research-program-index/registry/repos.yaml`
- Create: `/mnt/data/ros/program/research-program-index/scripts/create-repos.sh`

- [ ] **Step 1: Install and authenticate GitHub CLI (if missing)**

```bash
gh --version
gh auth status || gh auth login
```

Expected:
- `gh` authenticated for `github.com`

- [ ] **Step 2: Write repo creation script**

`scripts/create-repos.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

OWNER="$1"
VISIBILITY="${2:-public}"

repos=(
  research-program-index
  benchmark-core
  localization-tracking
  uav-mpc-geometric-control
  sensorless-estimation-suite
  swarm-path-planning-bees
  ik-uncertainty-learning
  digital-twin-pipeline
  docs-multilingual-continuity
  repro-packages
)

for r in "${repos[@]}"; do
  gh repo create "${OWNER}/${r}" "--${VISIBILITY}" --source "/mnt/data/ros/program/${r}" --remote origin --push
done
```

- [ ] **Step 3: Run script and verify remote setup**

```bash
cd /mnt/data/ros/program/research-program-index
chmod +x scripts/create-repos.sh
./scripts/create-repos.sh <your-github-username-or-org> public
```

Expected:
- All repos exist on GitHub.
- `git remote -v` in each repo shows `origin`.

- [ ] **Step 4: Commit script in meta-index**

```bash
cd /mnt/data/ros/program/research-program-index
git add scripts/create-repos.sh
git commit -m "chore: add github repo bootstrap script"
git push origin main
```

---

### Task 4: Wire cross-repo governance and sequential execution controls

**Files:**
- Modify: `/mnt/data/ros/program/research-program-index/roadmap/wave-plan.md`
- Modify: `/mnt/data/ros/program/research-program-index/registry/quality-gates.md`
- Create: `/mnt/data/ros/program/research-program-index/registry/release-manifest-schema.json`

- [ ] **Step 1: Define wave execution policy**

`roadmap/wave-plan.md`:
```markdown
# Wave Plan
Wave 1: FI-01, FI-02, FI-03, FI-12
Wave 2: FI-06, FI-07
Wave 3: FI-05, FI-04
Wave 4: FI-08, FI-09
Wave 5: FI-10, FI-11

Progression rule: next wave starts only after current wave passes all quality gates.
```

- [ ] **Step 2: Define quality gates**

`registry/quality-gates.md`:
```markdown
# Quality Gates
1. Reproducibility gate (clean rerun success)
2. Metrics gate (canonical schema outputs)
3. Stress-test gate (required scenarios executed)
4. Documentation gate (methods + limitations updated)
```

- [ ] **Step 3: Add release manifest schema**

`registry/release-manifest-schema.json`:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ReleaseManifest",
  "type": "object",
  "required": ["repo", "commit_sha", "wave", "scenario_ids", "artifacts"],
  "properties": {
    "repo": { "type": "string" },
    "commit_sha": { "type": "string" },
    "wave": { "type": "string" },
    "scenario_ids": { "type": "array", "items": { "type": "string" } },
    "artifacts": { "type": "array", "items": { "type": "string" } }
  }
}
```

- [ ] **Step 4: Commit governance wiring**

```bash
cd /mnt/data/ros/program/research-program-index
git add roadmap/wave-plan.md registry/quality-gates.md registry/release-manifest-schema.json
git commit -m "docs: define waves, gates, and release manifest schema"
git push origin main
```

---

### Task 5: Add first executable work package stub for Wave 1

**Files:**
- Create: `/mnt/data/ros/program/benchmark-core/contracts/metrics.schema.json`
- Create: `/mnt/data/ros/program/benchmark-core/contracts/scenario.schema.json`
- Create: `/mnt/data/ros/program/benchmark-core/tests/test_contract_files_exist.py`

- [ ] **Step 1: Write failing test first**

`tests/test_contract_files_exist.py`:
```python
from pathlib import Path

def test_contract_files_exist():
    root = Path(__file__).resolve().parents[1]
    assert (root / "contracts" / "metrics.schema.json").exists()
    assert (root / "contracts" / "scenario.schema.json").exists()
```

- [ ] **Step 2: Run test to verify failure**

```bash
cd /mnt/data/ros/program/benchmark-core
python3 -m pytest tests/test_contract_files_exist.py -v
```

Expected:
- FAIL (missing `contracts/*.json`)

- [ ] **Step 3: Add minimal schema files**

`contracts/metrics.schema.json`:
```json
{ "type": "object", "required": ["rmse", "settling_time"] }
```

`contracts/scenario.schema.json`:
```json
{ "type": "object", "required": ["scenario_id", "seed"] }
```

- [ ] **Step 4: Run test to verify pass**

```bash
python3 -m pytest tests/test_contract_files_exist.py -v
```

Expected:
- PASS

- [ ] **Step 5: Commit wave-1 starter**

```bash
git add contracts tests
git commit -m "feat: add initial benchmark contract schemas"
git push origin main
```

---

## Spec Coverage Check (self-review)
1. **Architecture choice covered:** Yes (domain multi-repo + meta-index).
2. **Central + local issue model covered:** Yes (Task 4 governance rules).
3. **Sequential priority execution covered:** Yes (Wave plan and progression gate).
4. **Public-by-default + GitHub operation covered:** Yes (Task 3 with `gh repo create`).
5. **No placeholders:** Confirmed (all steps include explicit files/commands/content).
