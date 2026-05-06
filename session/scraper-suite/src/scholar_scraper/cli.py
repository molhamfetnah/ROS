import argparse
import logging
from pathlib import Path

from .config import ScraperConfig
from .pipeline import run_parallel


def _logger(log_path: Path) -> logging.Logger:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger("scraper")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    fmt = logging.Formatter("%(asctime)s %(levelname)s %(message)s")

    sh = logging.StreamHandler()
    sh.setFormatter(fmt)
    logger.addHandler(sh)

    fh = logging.FileHandler(log_path, encoding="utf-8")
    fh.setFormatter(fmt)
    logger.addHandler(fh)
    return logger


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Parallel fulltext scraper")
    sub = p.add_subparsers(dest="cmd", required=True)

    run = sub.add_parser("run", help="Run scraper")
    run.add_argument("--index", type=Path, required=True)
    run.add_argument("--summary", type=Path, required=True)
    run.add_argument("--live", type=Path, required=True)
    run.add_argument("--pdf-dir", type=Path, required=True)
    run.add_argument("--log-file", type=Path, default=Path("/mnt/data/ros/session/artifacts/scraper.log"))
    run.add_argument("--workers", type=int, default=12)
    run.add_argument("--max-urls-per-paper", type=int, default=10)
    run.add_argument("--max-seconds-per-paper", type=int, default=45)
    run.add_argument("--http-timeout-seconds", type=int, default=20)
    run.add_argument("--statuses", nargs="+", default=["failed", "unavailable"])
    return p


def main() -> None:
    args = build_parser().parse_args()
    logger = _logger(args.log_file)
    cfg = ScraperConfig(
        index_path=args.index,
        summary_path=args.summary,
        live_path=args.live,
        pdf_dir=args.pdf_dir,
        workers=args.workers,
        max_urls_per_paper=args.max_urls_per_paper,
        max_seconds_per_paper=args.max_seconds_per_paper,
        http_timeout_seconds=args.http_timeout_seconds,
    )
    state = run_parallel(cfg, set(args.statuses), logger)
    logger.info("completed stage=%s done=%s downloaded_new=%s", state["stage"], state["done"], state["downloaded_new"])


if __name__ == "__main__":
    main()
