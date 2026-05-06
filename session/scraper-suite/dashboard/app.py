import csv
import json
from pathlib import Path

import streamlit as st
from streamlit_autorefresh import st_autorefresh

BASE = Path("/mnt/data/ros/session/artifacts")
LIVE = BASE / "live_status.json"
SUMMARY = BASE / "fulltext_download_summary.json"
INDEX = BASE / "fulltext_download_index.csv"
LOG = BASE / "scraper.log"

st.set_page_config(page_title="Scraper Live Status", layout="wide")
st_autorefresh(interval=2000, key="scraper-refresh")
st.title("Paper Scraper Live Dashboard")


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def load_index_sample(path: Path, limit: int = 20) -> list[dict]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    unresolved = [r for r in rows if r.get("status") in ("failed", "unavailable")]
    return unresolved[:limit]


live = load_json(LIVE)
summary = load_json(SUMMARY)

c1, c2, c3, c4 = st.columns(4)
c1.metric("Downloaded", summary.get("downloaded", 0))
c2.metric("Failed", summary.get("failed", 0))
c3.metric("Unavailable", summary.get("unavailable_or_paywalled", 0))
c4.metric("New Downloads (run)", summary.get("new_downloads_this_retry", 0))

done = int(live.get("done", 0) or 0)
total = int(live.get("queue_total", 0) or 0)
ratio = (done / total) if total else 0
st.progress(ratio, text=f"Progress {done}/{total}")
st.write(f"**Stage:** {live.get('stage', 'n/a')}")
st.write(f"**Current paper:** {live.get('current', 'n/a')}")
st.write(f"**Last update:** {live.get('updated_at', 'n/a')}")

st.subheader("Unresolved sample")
st.dataframe(load_index_sample(INDEX), use_container_width=True)

st.subheader("Latest logs")
if LOG.exists():
    lines = LOG.read_text(encoding="utf-8", errors="ignore").splitlines()[-40:]
    st.code("\n".join(lines), language="text")
else:
    st.info("No log file yet.")
