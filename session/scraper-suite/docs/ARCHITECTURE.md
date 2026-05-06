# Architecture

## Pipeline
1. Load index CSV (paper rows).
2. Filter rows by target statuses (`failed`, `unavailable` by default).
3. Process papers in parallel worker threads.
4. For each paper:
   - build candidate URLs (existing + OpenAlex + Unpaywall + DOI resolver),
   - attempt bounded download with timeout/limits,
   - update row status and note.
5. After each completed task:
   - write `fulltext_download_index.csv`,
   - write `fulltext_download_summary.json`,
   - write `live_status.json`.

## Concurrency model
- `ThreadPoolExecutor(max_workers=N)`
- Main thread handles durable checkpoint writes.
- Worker threads are network-bound; no shared mutable state writes.

## Safety controls
- Max URLs per paper.
- Max seconds per paper.
- HTTP timeout for each request.
- PDF signature/content checks before writing final success.

## Dashboard
- Streamlit app polling `live_status.json` + summary.
- Auto-refresh every 2 seconds.
- Shows progress, counters, current paper, and sample unresolved rows.
