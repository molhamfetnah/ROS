#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR/Google-Scholar-MCP-Server"
exec "$BASE_DIR/.venvs/google-scholar/bin/python" google_scholar_server.py
