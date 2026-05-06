import json
import urllib.parse
import urllib.request

USER_AGENT = "Mozilla/5.0"
CONTACT_EMAIL = "researcher@example.com"


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
    url = f"https://api.unpaywall.org/v2/{encoded}?email={CONTACT_EMAIL}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read().decode("utf-8", "ignore"))
    except Exception:
        return None
