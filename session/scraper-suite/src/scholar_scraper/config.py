from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ScraperConfig:
    index_path: Path
    summary_path: Path
    live_path: Path
    pdf_dir: Path
    workers: int = 12
    max_urls_per_paper: int = 10
    max_seconds_per_paper: int = 45
    http_timeout_seconds: int = 20
