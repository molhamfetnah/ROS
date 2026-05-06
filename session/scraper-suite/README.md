# Scraper Suite

Parallel, checkpointed full-text scraper with a live Streamlit dashboard.

## Features
- Multi-threaded scraping (`ThreadPoolExecutor`)
- Per-paper timeouts and URL-attempt limits
- Continuous checkpointing to CSV and JSON
- Live status file updated after each paper
- Streamlit dashboard with auto-refresh

## Project layout
- `src/scholar_scraper/` core scraper code
- `dashboard/app.py` live dashboard
- `docs/ARCHITECTURE.md` design notes
- `tests/` quick utility tests

## Setup
```bash
cd /mnt/data/ros/session/scraper-suite
python3 -m venv .venv
. .venv/bin/activate
pip install -e .
```

## Run scraper
```bash
. .venv/bin/activate
python -m scholar_scraper.cli run \
  --index /mnt/data/ros/session/artifacts/fulltext_download_index.csv \
  --summary /mnt/data/ros/session/artifacts/fulltext_download_summary.json \
  --live /mnt/data/ros/session/artifacts/live_status.json \
  --pdf-dir /mnt/data/ros/session/artifacts/full_papers_pdf \
  --workers 12 \
  --statuses failed unavailable
```

## Run dashboard
```bash
. .venv/bin/activate
streamlit run dashboard/app.py
```

## Live files
- `live_status.json`: always-updated progress and current paper
- `fulltext_download_summary.json`: aggregate counters
- `fulltext_download_index.csv`: checkpointed row-level status
