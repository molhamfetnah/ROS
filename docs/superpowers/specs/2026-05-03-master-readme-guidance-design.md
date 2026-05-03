# Master README Guidance Design

## Objective
Create a comprehensive, professional, command-driven root README for the ROS parent repository that guides users through onboarding and day-2 operations across the multi-repo structure.

## Scope
- In scope:
  - Rewrite `/mnt/data/ros/README.md`.
  - Cover parent repo architecture and role of each `program/*` subrepo.
  - Provide step-by-step commands for setup, operations, troubleshooting, and contribution workflow.
  - Include verification checkpoints and expected outcomes after key commands.
  - Link to deeper references in `docs/superpowers/` and `session/docs/`.
- Out of scope:
  - Rewriting READMEs in every subrepo.
  - Refactoring code or changing runtime behavior.

## Audience
- Primary: first-time contributors/operators.
- Secondary: returning maintainers handling operational workflows.
- Language: English only.

## Information Architecture
The README will follow this exact high-level structure:

1. **Project Overview**
   - Mission, what this repo orchestrates, and what it does not own.
2. **Repository Topology**
   - Parent repo responsibilities.
   - Submodule map (`program/*`) with one-line purpose per repo.
3. **Quick Start (10-Minute Path)**
   - Minimal onboarding path to get a clean working environment.
4. **Full Environment Setup**
   - Prerequisites, clone strategy, submodule sync/init, authentication notes.
5. **Operational Workflows (Day-2)**
   - Running tracking pipeline, scraper-related flows, operational checks, safe cleanup.
6. **Verification Checkpoints**
   - Command-level expected outputs and pass/fail indicators.
7. **Troubleshooting Playbooks**
   - Common failures seen in this project (git/submodule, PR base, SSH/HTTPS, shell shim).
8. **Contribution & Change Workflow**
   - Branching, test expectations, review sequencing, PR integration order.
9. **Safety, Recovery, and Cleanup**
   - Idempotent recovery commands, non-destructive cleanup, rollback steps.
10. **References**
   - Direct links to plan/spec files and key operational docs.

## Content Standards
- Command-first: each actionable step includes copy-paste commands.
- Every major procedure includes:
  - **Prerequisites**
  - **Execution**
  - **Validation**
  - **Recovery / rollback (when relevant)**
- Distinguish clearly:
  - Parent-repo commands vs submodule commands.
  - One-time setup vs routine operations.
- Use concise but professional tone; avoid ambiguity and placeholders.

## Critical Accuracy Requirements
- Must reflect the current submodule-based architecture in `program/*`.
- Must include explicit guardrails for common confusion points:
  - “No commits between branches” in parent repo vs nested repos.
  - Default branch/base branch mismatch.
  - SSH push failures and HTTPS fallback.
  - Worktree + submodule interactions.
- Must preserve legal/operational boundaries already established in project docs.

## Risks and Mitigations
- Risk: README becomes too monolithic and hard to scan.
  - Mitigation: strict sectioning, quick-start first, deep details lower in file.
- Risk: Commands become stale.
  - Mitigation: centralized references and clearly labeled command intent.
- Risk: Users run commands in wrong repo.
  - Mitigation: add path prompts and “Run from:” notes per section.

## Acceptance Criteria
- A new user can clone, initialize submodules, and run baseline workflows without external clarification.
- A maintainer can diagnose common operational failures using troubleshooting sections.
- README provides clear map to advanced docs without duplicating all deep content.
- All command blocks are path-scoped and include validation checkpoints.

