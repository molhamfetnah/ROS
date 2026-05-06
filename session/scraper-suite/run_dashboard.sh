#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -x "$ROOT/.venv/bin/streamlit" ]]; then
  echo "Missing virtualenv. Run: python3 -m venv .venv && . .venv/bin/activate && pip install -e ."
  exit 1
fi

export STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
export STREAMLIT_SERVER_HEADLESS=true

exec "$ROOT/.venv/bin/streamlit" run "$ROOT/dashboard/app.py"
