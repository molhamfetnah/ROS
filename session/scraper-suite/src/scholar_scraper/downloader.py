import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

USER_AGENT = "Mozilla/5.0"


def slug(text: str) -> str:
    text = (text or "").strip().lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return text[:120] or "paper"


def _request(url: str, accept: str | None = None) -> urllib.request.Request:
    headers = {"User-Agent": USER_AGENT}
    if accept:
        headers["Accept"] = accept
    return urllib.request.Request(url, headers=headers)


def extract_pdf_links(html: str, base_url: str) -> list[str]:
    links: list[str] = []
    for m in re.finditer(r'href=["\']([^"\']+)["\']', html, flags=re.I):
        url = urllib.parse.urljoin(base_url, m.group(1).strip())
        if ".pdf" in url.lower() or "/pdf" in url.lower() or "download" in url.lower():
            links.append(url)
    seen = set()
    out = []
    for u in links:
        if u not in seen:
            seen.add(u)
            out.append(u)
    return out


def try_download_with_limits(
    start_url: str,
    output_path: Path,
    http_timeout_seconds: int,
    max_urls_per_paper: int,
    max_seconds_per_paper: int,
) -> tuple[bool, str]:
    if not start_url:
        return False, "empty_url"

    queue = [start_url]
    seen = set()
    t0 = time.time()
    attempts = 0

    while queue and attempts < max_urls_per_paper:
        if time.time() - t0 > max_seconds_per_paper:
            return False, "timeout_guard"
        url = queue.pop(0)
        if url in seen:
            continue
        seen.add(url)
        attempts += 1
        try:
            req = _request(url, accept="application/pdf,*/*;q=0.8")
            with urllib.request.urlopen(req, timeout=http_timeout_seconds) as r:
                ctype = (r.headers.get("Content-Type") or "").lower()
                body = r.read()
        except Exception as e:
            note = f"open_error:{type(e).__name__}"
            continue

        if (b"%PDF" in body[:2048]) or ("pdf" in ctype):
            with output_path.open("wb") as f:
                f.write(body)
            if output_path.stat().st_size > 15_000:
                return True, f"ok:{url}"
            return False, "pdf_too_small"

        try:
            text = body.decode("utf-8", "ignore")
        except Exception:
            text = ""

        if "arxiv.org/abs/" in url:
            m = re.search(r"arxiv\.org/abs/([0-9]{4}\.[0-9]{4,5}(v\d+)?)", url)
            if m:
                queue.append(f"https://arxiv.org/pdf/{m.group(1)}.pdf")

        if text:
            queue.extend(extract_pdf_links(text, url)[:5])

    return False, "exhausted_or_nonpdf"
