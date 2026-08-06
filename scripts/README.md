# Scripts

Run all commands from the repository root.

## `validate_package.py`

Validates the following without network access:

- CSV headers and schemas;
- stable identifiers `S1`–`S6`;
- SHA-256 format and uniqueness;
- references between primary samples and secondary payloads;
- Boolean fields and collection-window format;
- basic indicator sanitization;
- required SBSeg 2026 README sections; and
- presence of the documented public scripts.

```bash
python3 scripts/validate_package.py
```

Requires Python 3.9 or later and only the standard library.

## `summarize_package.py`

Produces verifiable totals derived from the public CSV files. The default output is text; `--format json` produces JSON suitable for automated comparison.

```bash
python3 scripts/summarize_package.py
python3 scripts/summarize_package.py --format json
```

The script does not infer prevalence, attribution, or malicious behavior and does not contact external services.

## `extract_android_iocs.sh`

Optional static-analysis support pipeline for an APK supplied by the researcher. It computes hashes, inventories the ZIP, extracts DEX files, collects strings, and uses AAPT/APK Analyzer, APKTool, and JADX when available. APKTool decodes the manifest, resources, and Smali under `apktool/`; JADX produces an approximate Java representation under `jadx/sources/`. Indicator searches are heuristic and require human review.

```bash
bash scripts/extract_android_iocs.sh --help
bash scripts/extract_android_iocs.sh /authorized/path/sample.apk analysis-output
```

The script does not download, install, or execute the APK and does not initiate network access. It must still be used only in an isolated environment and with authorization. Git ignores the default `analysis-output/` directory and executable formats. Do not publish outputs without sanitization.

Required and optional dependencies are listed in the main README. The original investigation environment is documented in `methodology/analysis_environment.md`.
