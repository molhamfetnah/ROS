#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -x "$ROOT/.venv/bin/python" ]]; then
  echo "Missing virtualenv. Run: python3 -m venv .venv && . .venv/bin/activate && pip install -e ."
  exit 1
fi

exec "$ROOT/.venv/bin/python" -m scholar_scraper.cli run \
  --index /mnt/data/ros/session/artifacts/fulltext_download_index.csv \
  --summary /mnt/data/ros/session/artifacts/fulltext_download_summary.json \
  --live /mnt/data/ros/session/artifacts/live_status.json \
  --pdf-dir /mnt/data/ros/session/artifacts/full_papers_pdf \
  --workers "${SCRAPER_WORKERS:-12}" \
  --max-urls-per-paper "${SCRAPER_MAX_URLS_PER_PAPER:-10}" \
  --max-seconds-per-paper "${SCRAPER_MAX_SECONDS_PER_PAPER:-45}" \
  --http-timeout-seconds "${SCRAPER_HTTP_TIMEOUT_SECONDS:-20}" \
  --statuses failed unavailable
