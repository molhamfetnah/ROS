# Git Status Tracking Design (ROS Parent Repo)

## Problem
We need persistent tracking of repository file-state changes in the ROS parent repo, with automatic capture whenever `git status` is run, and with append-only history plus a latest snapshot.

## Scope
- In scope: ROS parent repo only (`/mnt/data/ros` top-level).
- In scope: track untracked, modified, deleted, and renamed paths.
- Out of scope: tracking inside `program/*` submodules.

## Approach
Implement a shell-level `git` shim (Bash function) that intercepts `git status` and `git st`:
1. Detect current git top-level.
2. If top-level equals ROS parent repo, run tracker collector.
3. Collector writes tracking artifacts.
4. Always forward command to the real git binary.
5. For non-status git commands, pass through unchanged.

## Tracking Artifacts
Store under repo-local `.tracking/`:

- `latest.json`: latest full structured snapshot.
- `history.ndjson`: append-only event history (one JSON object per line).
- `latest.txt`: readable summary for quick inspection.

Each tracking event includes:
- `timestamp` (ISO-8601)
- `repo_root`
- `branch`
- `untracked[]`
- `modified[]`
- `deleted[]`
- `renamed[]`

## Data Flow
1. User runs `git status` (or `git st`).
2. Bash shim checks repo root.
3. If ROS parent repo, capture `git status --porcelain=v1` and parse by status code.
4. Generate snapshot object and write:
   - overwrite `latest.json`
   - append to `history.ndjson`
   - overwrite `latest.txt`
5. Execute original `git status` output for user.

## Error Handling
- Tracker failures must not block git usage.
- On parser or write failure, print a warning to stderr and continue to real git command.
- If `.tracking/` is missing, create it automatically.
- If `history.ndjson` exceeds size threshold, rotate to `history.<timestamp>.ndjson` and continue with new file.

## Safety Constraints
- Run collector only when top-level repo path exactly matches `/mnt/data/ros`.
- Never recurse into submodules for collection.
- Never modify tracked source files; only write under `.tracking/`.

## Implementation Units
1. **Collector script** (`scripts/track-git-status.sh`)
   - Read porcelain output
   - Parse and build JSON payload
   - Write artifacts and rotate history
2. **Shell shim snippet** (`session/docs/snippets/git-tracking-shim.bash`)
   - Function override for `git`
   - Conditional call to collector for `status`/`st`
3. **Installer helper** (`scripts/install-git-tracking-shim.sh`)
   - Idempotently append shim source block to `~/.bashrc`

## Validation Plan
- Run `git status` with known untracked/modified/deleted/renamed examples.
- Confirm `.tracking/latest.json`, `.tracking/history.ndjson`, `.tracking/latest.txt` are produced.
- Confirm multiple `git status` calls append events.
- Confirm non-status git commands are unaffected.
- Confirm tracker does not run in submodules.

## Success Criteria
- Every `git status` in ROS parent repo produces/updates tracking artifacts.
- History is append-only and survives shell sessions.
- Tracker is transparent to normal git workflow.
- Submodule repositories are not tracked by this mechanism.
