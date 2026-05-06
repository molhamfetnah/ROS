from __future__ import annotations

import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from .config import ScraperConfig
from .downloader import slug, try_download_with_limits
from .io_utils import load_index, write_index, write_live, write_summary
from .sources import openalex, unpaywall


def _candidate_urls(row: dict, http_timeout: int) -> list[str]:
    urls: list[str] = []
    for key in ("pdf_url", "landing_url"):
        if row.get(key):
            urls.append(row[key].strip())

    doi = (row.get("doi") or "").strip()
    title = (row.get("title") or "").strip()

    if doi:
        up = unpaywall.by_doi(doi, timeout=http_timeout)
        if up:
            best = up.get("best_oa_location") or {}
            if best.get("url_for_pdf"):
                urls.append(best["url_for_pdf"])
            if best.get("url"):
                urls.append(best["url"])
            for loc in (up.get("oa_locations") or [])[:5]:
                if loc.get("url_for_pdf"):
                    urls.append(loc["url_for_pdf"])
                if loc.get("url"):
                    urls.append(loc["url"])

    oa = openalex.by_doi(doi, timeout=http_timeout) if doi else None
    if not oa and title:
        oa = openalex.by_title(title, timeout=http_timeout)
    if oa:
        best = oa.get("best_oa_location") or {}
        primary = oa.get("primary_location") or {}
        for u in (
            best.get("pdf_url"),
            best.get("landing_page_url"),
            primary.get("pdf_url"),
            primary.get("landing_page_url"),
        ):
            if u:
                urls.append(u)
        if not doi and oa.get("doi"):
            doi = oa["doi"]

    if doi:
        clean = (
            doi.lower()
            .replace("https://doi.org/", "")
            .replace("http://doi.org/", "")
            .replace("doi:", "")
        )
        urls.append(f"https://doi.org/{clean}")

    seen = set()
    out = []
    for u in urls:
        if u and u not in seen:
            seen.add(u)
            out.append(u)
    return out


def _process_one(row: dict, cfg: ScraperConfig) -> tuple[dict, str]:
    title = row.get("title", "")
    year = row.get("year", "")
    output = cfg.pdf_dir / f"{year}_{slug(title)}.pdf"

    if output.exists() and output.stat().st_size > 15_000:
        row["status"] = "downloaded"
        row["file_path"] = str(output)
        row["note"] = "already_exists"
        return row, "already_exists"

    urls = _candidate_urls(row, cfg.http_timeout_seconds)[: cfg.max_urls_per_paper]
    if not urls:
        row["status"] = "unavailable"
        row["note"] = "no_candidate_urls"
        return row, "no_candidate_urls"

    last_note = "exhausted"
    for url in urls:
        ok, note = try_download_with_limits(
            start_url=url,
            output_path=output,
            http_timeout_seconds=cfg.http_timeout_seconds,
            max_urls_per_paper=cfg.max_urls_per_paper,
            max_seconds_per_paper=cfg.max_seconds_per_paper,
        )
        last_note = note
        if ok:
            row["status"] = "downloaded"
            row["file_path"] = str(output)
            row["note"] = note
            return row, f"downloaded:{url}"

    row["status"] = "failed"
    row["note"] = last_note
    return row, f"failed:{last_note}"


def run_parallel(cfg: ScraperConfig, target_statuses: set[str], logger: logging.Logger) -> dict:
    rows = load_index(cfg.index_path)
    pending = [(i, row) for i, row in enumerate(rows) if row.get("status") in target_statuses]

    logger.info("queue=%s workers=%s", len(pending), cfg.workers)
    state = {
        "stage": "running",
        "queue_total": len(pending),
        "done": 0,
        "downloaded_new": 0,
        "current": "",
    }
    write_live(cfg.live_path, state)

    with ThreadPoolExecutor(max_workers=cfg.workers) as ex:
        futs = {ex.submit(_process_one, row.copy(), cfg): i for i, row in pending}
        done = 0
        new_downloads = 0
        fields = rows[0].keys()
        for fut in as_completed(futs):
            pos = futs[fut]
            updated, result = fut.result()
            before = rows[pos].get("status")
            rows[pos].update(updated)
            after = rows[pos].get("status")
            if before != "downloaded" and after == "downloaded":
                new_downloads += 1

            done += 1
            state.update(
                {
                    "done": done,
                    "downloaded_new": new_downloads,
                    "current": updated.get("title", ""),
                }
            )
            write_index(cfg.index_path, rows, fields)
            write_summary(cfg.summary_path, rows, new_downloads, cfg.pdf_dir, cfg.index_path)
            write_live(cfg.live_path, state)
            logger.info("done=%s/%s result=%s title=%s", done, len(pending), result, updated.get("title", ""))

    state["stage"] = "done"
    write_live(cfg.live_path, state)
    write_summary(cfg.summary_path, rows, state["downloaded_new"], cfg.pdf_dir, cfg.index_path)
    return state
