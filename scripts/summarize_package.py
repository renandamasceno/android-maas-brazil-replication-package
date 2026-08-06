#!/usr/bin/env python3
"""Summarize verifiable results from the public replication-package metadata."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"


def read_csv(name: str) -> list[dict[str, str]]:
    with (DATA / name).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def build_summary() -> dict[str, int | str]:
    manifest = read_csv("sample_manifest.csv")
    secondary = read_csv("secondary_payloads.csv")
    infrastructure = read_csv("sanitized_infrastructure.csv")

    secondary_sources = sorted({row["source_sample"] for row in secondary})
    infrastructure_samples = {row["sample_id"] for row in infrastructure}

    return {
        "primary_samples": len(manifest),
        "static_analysis_samples": sum(
            row["static_analysis"] == "true" for row in manifest
        ),
        "dynamic_analysis_samples": sum(
            row["dynamic_analysis"] == "true" for row in manifest
        ),
        "secondary_payloads": len(secondary),
        "secondary_source_samples": ",".join(secondary_sources),
        "sanitized_infrastructure_entries": len(infrastructure),
        "infrastructure_sample_coverage": len(infrastructure_samples),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Summarize the public metadata without network access."
    )
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="output format (default: text)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    summary = build_summary()
    if args.format == "json":
        print(json.dumps(summary, indent=2, sort_keys=True))
    else:
        for key, value in summary.items():
            print(f"{key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
