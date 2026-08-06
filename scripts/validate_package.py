#!/usr/bin/env python3
"""Validate the public replication-package metadata without network access."""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
SAMPLE_RE = re.compile(r"^S[1-6]$")
WINDOW_RE = re.compile(r"^\d{4}-(?:0[1-9]|1[0-2])/\d{4}-(?:0[1-9]|1[0-2])$")

REQUIRED_README_SECTIONS = {
    "paper abstract and artifact objective",
    "readme structure",
    "badges considered",
    "basic information",
    "dependencies",
    "security concerns",
    "installation",
    "minimum test",
    "experiments",
    "license",
}

REQUIRED_PUBLIC_FILES = {
    ".github/workflows/validate.yml",
    "LICENSE",
    "CITATION.cff",
    "scripts/extract_android_iocs.sh",
    "scripts/summarize_package.py",
    "scripts/validate_package.py",
}

EXPECTED_HEADERS = {
    "sample_manifest.csv": [
        "sample_id",
        "sha256",
        "collection_window",
        "lure_theme",
        "delivery_method",
        "static_analysis",
        "dynamic_analysis",
    ],
    "secondary_payloads.csv": ["source_sample", "artifact", "sha256"],
    "sanitized_infrastructure.csv": [
        "sample_id",
        "artifact_type",
        "sanitized_value",
    ],
}


def read_csv(name: str) -> list[dict[str, str]]:
    path = DATA / name
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != EXPECTED_HEADERS[name]:
            raise ValueError(
                f"{name}: expected header {EXPECTED_HEADERS[name]}, got {reader.fieldnames}"
            )
        return list(reader)


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def validate_public_documentation(errors: list[str]) -> None:
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    headings = {
        line.lstrip("#").strip().lower()
        for line in readme.splitlines()
        if line.startswith("#")
    }
    for section in sorted(REQUIRED_README_SECTIONS):
        require(section in headings, f"README.md: missing required section: {section}", errors)

    for relative_path in sorted(REQUIRED_PUBLIC_FILES):
        require((ROOT / relative_path).is_file(), f"missing public file: {relative_path}", errors)


def main() -> int:
    errors: list[str] = []

    validate_public_documentation(errors)

    manifest = read_csv("sample_manifest.csv")
    secondary = read_csv("secondary_payloads.csv")
    infrastructure = read_csv("sanitized_infrastructure.csv")

    sample_ids = [row["sample_id"] for row in manifest]
    sample_hashes = [row["sha256"] for row in manifest]
    require(len(manifest) == 6, "sample_manifest.csv: expected exactly six rows", errors)
    require(set(sample_ids) == {f"S{i}" for i in range(1, 7)}, "sample_manifest.csv: expected S1-S6", errors)
    require(len(sample_ids) == len(set(sample_ids)), "sample_manifest.csv: duplicate sample ID", errors)
    require(len(sample_hashes) == len(set(sample_hashes)), "sample_manifest.csv: duplicate SHA-256", errors)

    for line, row in enumerate(manifest, start=2):
        require(bool(SAMPLE_RE.fullmatch(row["sample_id"])), f"sample_manifest.csv:{line}: invalid sample ID", errors)
        require(bool(SHA256_RE.fullmatch(row["sha256"])), f"sample_manifest.csv:{line}: invalid SHA-256", errors)
        require(bool(WINDOW_RE.fullmatch(row["collection_window"])), f"sample_manifest.csv:{line}: invalid collection window", errors)
        for field in ("static_analysis", "dynamic_analysis"):
            require(row[field] in {"true", "false"}, f"sample_manifest.csv:{line}: {field} must be true or false", errors)
        for field in ("collection_window", "lure_theme", "delivery_method"):
            require(bool(row[field].strip()), f"sample_manifest.csv:{line}: empty {field}", errors)

    all_hashes = set(sample_hashes)
    for line, row in enumerate(secondary, start=2):
        require(row["source_sample"] in set(sample_ids), f"secondary_payloads.csv:{line}: unknown source sample", errors)
        require(bool(SHA256_RE.fullmatch(row["sha256"])), f"secondary_payloads.csv:{line}: invalid SHA-256", errors)
        require(bool(row["artifact"].strip()), f"secondary_payloads.csv:{line}: empty artifact", errors)
        require(row["sha256"] not in all_hashes, f"secondary_payloads.csv:{line}: duplicate SHA-256", errors)
        all_hashes.add(row["sha256"])

    for line, row in enumerate(infrastructure, start=2):
        value = row["sanitized_value"]
        require(row["sample_id"] in set(sample_ids), f"sanitized_infrastructure.csv:{line}: unknown sample", errors)
        require(row["artifact_type"] in {"domain", "domain_pattern"}, f"sanitized_infrastructure.csv:{line}: invalid artifact type", errors)
        require("[.]" in value, f"sanitized_infrastructure.csv:{line}: value is not defanged", errors)
        require("://" not in value, f"sanitized_infrastructure.csv:{line}: URL scheme is not allowed", errors)
        require("@" not in value, f"sanitized_infrastructure.csv:{line}: possible credential material", errors)

    require(
        {row["sample_id"] for row in infrastructure} == set(sample_ids),
        "sanitized_infrastructure.csv: expected coverage of all samples",
        errors,
    )

    if errors:
        print("Validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"Validation passed: {len(manifest)} samples, "
        f"{len(secondary)} secondary payloads, "
        f"{len(infrastructure)} sanitized infrastructure entries."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
