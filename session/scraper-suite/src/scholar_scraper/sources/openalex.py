import json
import urllib.parse
import urllib.request

USER_AGENT = "Mozilla/5.0"


def _fetch_json(url: str, timeout: int = 20) -> dict | None:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read().decode("utf-8", "ignore"))
    except Exception:
        return None


def by_title(title: str, timeout: int = 20) -> dict | None:
    q = urllib.parse.quote(title)
    url = (
        "https://api.openalex.org/works"
        f"?search={q}&per-page=3"
        "&select=display_name,doi,best_oa_location,primary_location"
    )
    data = _fetch_json(url, timeout=timeout)
    if not data:
        return None
    items = data.get("results", [])
    return items[0] if items else None


def by_doi(doi: str, timeout: int = 20) -> dict | None:
    clean = (
        doi.strip()
        .lower()
        .replace("https://doi.org/", "")
        .replace("http://doi.org/", "")
        .replace("doi:", "")
    )
    if not clean:
        return None
    encoded = urllib.parse.quote(clean, safe="")
    url = (
        "https://api.openalex.org/works/https://doi.org/"
        f"{encoded}?select=display_name,doi,best_oa_location,primary_location"
    )
    return _fetch_json(url, timeout=timeout)
