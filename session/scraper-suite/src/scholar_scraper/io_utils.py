import csv
import json
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Iterable


def now_iso() -> str:
    return datetime.now().isoformat()


def load_index(path: Path) -> list[dict]:
    with path.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def write_index(path: Path, rows: list[dict], fieldnames: Iterable[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)


def count_status(rows: list[dict]) -> dict:
    c = Counter(r.get("status", "") for r in rows)
    return dict(c)


def write_summary(path: Path, rows: list[dict], new_downloads: int, pdf_dir: Path, index_path: Path) -> None:
    counts = count_status(rows)
    payload = {
        "candidates_total": len(rows),
        "downloaded": counts.get("downloaded", 0),
        "failed": counts.get("failed", 0),
        "unavailable_or_paywalled": counts.get("unavailable", 0),
        "new_downloads_this_retry": new_downloads,
        "pdf_dir": str(pdf_dir),
        "index_file": str(index_path),
        "updated_at": now_iso(),
    }
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)


def write_live(path: Path, payload: dict) -> None:
    payload = dict(payload)
    payload["updated_at"] = now_iso()
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
