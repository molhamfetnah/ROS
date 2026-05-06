# Professional Academic Research Workflow
## From Research to Publication - Complete Step-by-Step Guide

This document provides a comprehensive, step-by-step workflow for conducting academic research, implementing algorithms, and publishing in peer-reviewed journals. Based on the successful completion of the "Modernized Bees Algorithm for Dynamic Path Planning in Robotics" project.

---

## Table of Contents

1. [Research Phase](#1-research-phase)
2. [Project Selection](#2-project-selection)
3. [Implementation](#3-implementation)
4. [Testing & Benchmarking](#4-testing--benchmarking)
5. [Documentation](#5-documentation)
6. [Publication Strategy](#6-publication-strategy)
7. [Journal Submission](#7-journal-submission)
8. [Post-Submission](#8-post-submission)

---

## 1. Research Phase

### 1.1 Literature Review

**Objective:** Identify foundational work in your target area

**Steps:**
1. Use Google Scholar, arXiv, Scopus, Web of Science
2. Search for key researchers in the field
3. Identify 3-5 foundational papers
4. Analyze citations and references

**Our Example:**
- Target researcher: Prof. A.K.M. Joukhadar (University of Aleppo)
- Search terms: "Bees Algorithm", "path planning", "sensorless control"
- Found: 53 papers spanning 2001-2024

### 1.2 Identify Research Gap

**Questions to answer:**
- What limitations exist in current work?
- What can be improved?
- What is the practical application?

**Our Gap Analysis:**
| Area | Limitation | Our Solution |
|------|------------|--------------|
| Static environments only | No dynamic obstacle handling | Added real-time replanning |
| Single objective | Only path length | Multi-objective optimization |
| Fixed parameters | No adaptation | Adaptive parameter tuning |

---

## 2. Project Selection

### 2.1 Choose Implementation Project

**Criteria:**
- Feasibility (can complete in 1-3 months)
- Clear connection to foundational work
- Publishable results
- Open-source ready

### 2.2 Set Up GitHub Repository

**Steps:**
1. Create GitHub account (github.com/molhamfetnah)
2. Create new repository: `swarm-path-planning-bees`
3. Initialize with README
4. Add .gitignore for Python
5. Add LICENSE (see Section 6.3)

**Repository Structure:**
```
swarm-path-planning-bees/
├── src/                  # Source code
│   ├── algorithms/      # Core algorithm
│   └── wrappers/        # ROS integration
├── tests/               # Test suite
│   ├── unit/            # Unit tests
│   ├── integration/     # Integration tests
│   └── stress/          # Stress tests
├── benchmarks/          # Benchmark scripts
├── paper/               # Paper drafts
│   ├── arxiv/           # arXiv submission
│   └── journal/         # Journal submission
├── docs/                # Documentation
├── simulations/         # Simulation files
├── requirements.txt     # Dependencies
└── setup.py            # Package setup
```

---

## 3. Implementation

### 3.1 Algorithm Development

**Core Components:**

1. **Core Algorithm** (`src/algorithms/bees_algorithm.py`)
   - Scout bee phase
   - Site selection
   - Recruitment
   - Neighborhood search

2. **Modernizations:**
   - Adaptive parameter tuning
   - Multi-objective fitness function
   - Dynamic obstacle handling
   - Early termination criteria

3. **Configuration:**
   ```python
   @dataclass
   class PlanningConfig:
       n_scout_bees: int = 50
       n_elite_sites: int = 5
       n_best_sites: int = 20
       max_iterations: int = 500
       adaptive_neighborhood: bool = True
   ```

### 3.2 Code Quality Standards

- Use type hints
- Write docstrings for all functions
- Follow PEP 8 style guide
- Create __init__.py for packages

### 3.3 Version Control

**Commands:**
```bash
# Initialize (if not submodule)
git init

# Add files
git add -A

# Commit with descriptive message
git commit -m "feat: implement modernized Bees Algorithm..."

# Push to remote
git push origin master
```

---

## 4. Testing & Benchmarking

### 4.1 Benchmark Design

**Test Scenarios:**
| Scenario | Description | Difficulty |
|----------|-------------|-------------|
| S1 | Empty environment | Easy |
| S2 | Single obstacle | Easy |
| S3 | Multiple obstacles | Medium |
| S4 | Maze | Hard |
| S5 | Narrow passage | Hard |
| D1 | Dynamic obstacles | Hard |

### 4.2 Running Benchmarks

```bash
cd swarm-path-planning-bees
PYTHONPATH=. python3 benchmarks/run_all.py
```

**Results Format:**
- CSV for data analysis
- JSON for programmatic access
- Summary report (PDF/PNG visualization)

### 4.3 Success Criteria

| Metric | Target |
|--------|--------|
| Success Rate | 100% |
| Avg Planning Time | < 1 second |
| Iterations to Converge | < 50 |

---

## 5. Documentation

### 5.1 Project Documentation

**Required Files:**

| File | Purpose |
|------|---------|
| README.md | Project overview, quick start |
| CONTRIBUTING.md | How to contribute |
| requirements.txt | Python dependencies |
| setup.py | Package installation |
| LICENSE | License terms |

### 5.2 Academic Documentation

| Document | Purpose |
|----------|---------|
| evaluation_protocol.md | Metrics and test scenarios |
| paper/outline.md | Paper structure |
| paper/manuscript.md | Full paper draft |
| docs/academic_commentary.md | Notes on related work |

### 5.3 Code Documentation

```python
def run(self, start, goal, obstacles):
    """
    Run the Bees Algorithm to find a path from start to goal.
    
    Args:
        start: numpy array [x, y] - starting position
        goal: numpy array [x, y] - goal position
        obstacles: list of numpy arrays - obstacle positions
    
    Returns:
        path: list of numpy arrays - waypoints
        stats: dict - optimization statistics
    """
```

---

## 6. Publication Strategy

### 6.1 Choose Publication Path

| Option | Pros | Cons | Time |
|--------|------|------|------|
| **arXiv Preprint** | Fast, establishes priority | No peer review | 1-2 days |
| **Journal** | Peer reviewed, prestigious | Slow | 2-12 months |
| **Conference** | Fast feedback | Competitive | 3-6 months |

**Our Decision:** Journal (Applied Soft Computing)

**Rationale:**
- Elsevier/Scopus indexed
- 2-4 month review time
- Focus on algorithm optimization
- No travel required (Syrian passport restrictions)

### 6.2 Choose Target Journal

**Evaluation Criteria:**
- Review time (shorter = better)
- Indexing (Scopus, Web of Science)
- Impact factor
- Fit with paper scope

**Our Selection: Applied Soft Computing (Elsevier)**
- Review time: 2-4 months
- Indexed: Scopus, Web of Science
- Impact factor: ~8.0
- Focus: Algorithm optimization, soft computing

### 6.3 Choose License

| License | Allows Commercial | Derivatives | Attribution |
|---------|-------------------|--------------|-------------|
| **CC BY-NC-ND** | ❌ | ❌ | ✅ | ✅ | ✅ |
| CC BY | ✅ | ✅ | ✅ | ✅ |
| CC BY-SA | ✅ | ✅ (same license) | ✅ |
| CC0 | ✅ | ✅ | ❌ |

**Our Choice:** CC BY-NC-ND
- Keeps commercial rights with author
- No derivatives allowed (protects integrity)
- Attribution required (proper credit)

---

## 7. Journal Submission

### 7.1 Submission Checklist

| Item | Status |
|------|--------|
| Manuscript (PDF/DOCX) | ✅ |
| Cover Letter | ✅ |
| Highlights (3-5 bullet points) | ✅ |
| Author declarations | ✅ |
| Conflict of interest form | ✅ |
| Repository link | ✅ |

### 7.2 Elsevier Submission Steps

1. **Go to:** https://www.editorialmanager.com/asoc/
2. **Register/Login** with email
3. **Select Classifications:**
   - Swarm intelligence
   - Metaheuristics
   - Robotics and Autonomous Systems
   - Evolutionary Computing
   - Multi-objective Optimisation

4. **Upload Files:**
   - Manuscript (Word/PDF)
   - Cover Letter
   - Highlights

5. **Fill Metadata:**
   - Title, Abstract, Keywords
   - Author information
   - Corresponding author designation

6. **Submit!**

### 7.3 Submission Confirmation

**Manuscript ID:** ASOC-D-26-06746

**Confirmation Email Received:** May 6, 2026

---

## 8. Post-Submission

### 8.1 Tracking Progress

**URL:** https://www.editorialmanager.com/ASOC

**Login:** Username: Mulham Fetna

**Status Stages:**
1. With Editor (1-2 weeks)
2. Under Review (2-4 months)
3. Required Reviews Complete
4. Decision (Accept/Revise/Reject)

### 8.2 arXiv Backup (Optional)

**If arXiv endorsement received:**
1. Upload to arXiv
2. Get arXiv ID (e.g., arXiv:2505.XXXXX)
3. Add to paper as "Preprint. arXiv:XXXXX"
4. Continue with journal

### 8.3 If Rejected

**Options:**
1. Revise and resubmit to same journal
2. Transfer to alternative Elsevier journal
3. Submit to different journal

---

## Appendix: Useful Commands

### Git Submodule Management

```bash
# Initialize all submodules
git submodule update --init --recursive

# Checkout master for all
cd program/swarm-path-planning-bees
git checkout master
git pull

# Check submodule status
git submodule status
```

### PDF Generation

```bash
# Using pandoc
pandoc paper.md -o paper.pdf

# Using LaTeX
pdflatex paper.tex
```

### Python Development

```bash
# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .

# Run tests
pytest tests/

# Run benchmarks
python benchmarks/run_all.py
```

---

## Timeline Summary

| Phase | Duration | Status |
|-------|----------|--------|
| Research & Literature Review | 1-2 weeks | ✅ Complete |
| Project Setup | 1 day | ✅ Complete |
| Implementation | 1-2 weeks | ✅ Complete |
| Testing & Benchmarking | 1 week | ✅ Complete |
| Paper Writing | 1 week | ✅ Complete |
| Journal Submission | 1 day | ✅ Complete |
| Review Process | 2-4 months | ⏳ Pending |

---

## Repository Links

| Resource | Link |
|----------|------|
| Main Project | https://github.com/molhamfetnah/ROS |
| swarm-path-planning-bees | https://github.com/molhamfetnah/swarm-path-planning-bees |
| Submission Package | https://github.com/molhamfetnah/swarm-path-planning-bees/tree/main/paper/journal/SUBMISSION_READY |
| Editorial Manager | https://www.editorialmanager.com/asoc |

---

**Document Version:** 1.0  
**Created:** May 6, 2026  
**Based on:** Successful journal submission ASOC-D-26-06746