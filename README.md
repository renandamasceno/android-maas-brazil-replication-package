# Android MaaS Brazil Replication Package

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21767014.svg)](https://doi.org/10.5281/zenodo.21767014)

This repository accompanies the paper:

> **Characterizing Malware-as-a-Service-Oriented Android Fraud Campaigns Targeting Brazil**
>
> José Renan F. Damasceno, Carlos Adriel Sousa Bastos, Francisco Lucas Falcão Pereira, Emanuel Bezerra Rodrigues, and Paulo Antonio Leal Rego.

## Paper abstract and artifact objective

Android fraud campaigns increasingly exhibit Malware-as-a-Service (MaaS)-oriented operational practices, including reusable delivery infrastructures, staged payload workflows, and backend-supported malware capabilities. This paper presents an exploratory characterization of Brazilian-targeting Android fraud campaigns through the analysis of phishing delivery infrastructures, malware behavior, and operational artifacts. Using OSINT-driven infrastructure discovery, static analysis, DEX-centric reverse engineering, and dynamic execution on physical devices across six real-world Android malware samples, we identified recurring patterns involving fake Google Play-style delivery pages, APK sideloading, PT-BR localized social engineering, Accessibility Services abuse, WebView-supported phishing interactions, staged payload delivery, C2 communication, and anti-analysis mechanisms. The campaigns ranged from phishing-oriented applications to more intrusive malware implementing overlay-capable flows, remote backend communication, and NFC/EMV payment-card interaction capabilities. Cross-sample correlation revealed partially shared protocol logic, reused delivery workflows, and overlapping operational artifacts, suggesting MaaS-oriented development and deployment practices in Brazilian-targeting Android fraud operations.

This package publishes SHA-256 identifiers and metadata for the six samples, identifiers for three secondary payloads, sanitized infrastructure indicators, methodological protocols, the analysis-environment specification, and local scripts for validation, summarization, and authorized static indicator extraction. Malware binaries, victim data, and operational endpoints are not distributed.

## README structure

This README declares the requested badges, describes the environment and dependencies, records safety requirements, and provides installation, minimum-test, and experiment instructions. “Repository structure” locates each component; “Experiments” maps verifiable claims to commands and expected results; “Reproducibility limitations” defines what cannot be reproduced from the public material.

## Badges considered

We request evaluation for the following SBSeg artifact badges:

- **Available Artifacts (Selo D):** source code, sanitized data, and documentation are publicly available on GitHub and in an archived Zenodo deposit.
- **Functional Artifacts (Selo F):** the validation and summarization scripts run without network access and expose the public package functionality; the static extractor can be used separately with an APK legally obtained by the evaluator.
- **Sustainable Artifacts (Selo S):** data, scripts, and methodology are separated, documented, and mapped to the verifiable claims.

The **Reproducible Experiments badge (Selo R) is not requested** for this version. Full reproduction of the historical investigation would require malware APKs, past remote-infrastructure state, external triggers, and device conditions that cannot be safely distributed or preserved. The public experiments below verify consistency and results derived from the released metadata, but they do not replay the complete dynamic investigation reported in the paper.

## Basic information

### Primary public functionality

The minimum test and metadata experiments run on Linux, macOS, or Windows with Python 3.9 or later. They do not access the network, execute malware, or require third-party Python packages.

Recommended resources for this part:

- 1 CPU core;
- 100 MB of available RAM;
- 20 MB of free disk space; and
- a terminal with Python 3.9 or later.

### Optional static extraction

The `scripts/extract_android_iocs.sh` script is only for researchers who already have legal and institutionally authorized access to a sample. Linux in a disposable virtual machine is recommended, without credentials, shared personal folders, or unnecessary network access. The script does not install or execute the APK: it computes hashes, extracts DEX files, uses APKTool to decode the manifest, resources, and Smali, uses JADX to produce an approximate Java representation, and generates local triage files. APKTool and JADX are optional; their absence does not prevent basic hash, inventory, and string extraction.

The environment used in the original study—including a Samsung Galaxy A32, Android 13, Magisk 30.7, JADX 1.5.5, apktool 2.7.0-dirty, and MobSF 4.5.0—is documented in [`methodology/analysis_environment.md`](methodology/analysis_environment.md). This device is not required for the minimum test.

## Repository structure

```text
.
|-- CITATION.cff                 # citation metadata
|-- LICENSE                      # license for the public material
|-- README.md                    # artifact-evaluation instructions
|-- .github/workflows/validate.yml
|-- data/
|   |-- README.md                # data dictionary
|   |-- sample_manifest.csv      # six primary samples
|   |-- sanitized_infrastructure.csv
|   `-- secondary_payloads.csv   # secondary payloads related to S1
|-- methodology/                 # acquisition, selection, environment, workflow
|-- queries/                     # representative OSINT query
`-- scripts/
    |-- README.md
    |-- extract_android_iocs.sh  # optional static extraction
    |-- summarize_package.py     # reproducible metadata summary
    `-- validate_package.py      # schema and consistency validation
```

## Dependencies

| Component | Version | Required | Purpose |
| --- | --- | --- | --- |
| Python | 3.9 or later | Yes | validation, summarization, and public experiments |
| Python standard library | matching Python version | Yes | no PyPI dependency is used |
| Bash | 3.2 or later | Optional extraction only | static-extractor execution |
| System utilities (`unzip`, `zipinfo`, `strings`, `grep`, `sed`, `awk`, `sort`, `head`, `basename`, `tr`, `wc`, `cp`) | OS-provided version | Optional extraction only | inventory and static triage |
| `sha256sum` or `shasum` | OS-provided version | Optional extraction only | SHA-256 calculation |
| `md5sum` or `md5` | OS-provided version | Optional extraction only | auxiliary MD5 calculation |
| AAPT or APK Analyzer | version compatible with the APK | Optional | manifest and permission extraction |
| APKTool | 2.7.0-dirty in the original study | Optional | manifest, resource, and Smali decoding |
| JADX | 1.5.5 recommended | Optional | static decompilation |
| GNU `timeout` or `gtimeout` | OS-provided version | Optional | 20-minute limit for APKTool and JADX |

No keys, external accounts, cloud services, or third-party benchmarks are needed for the minimum test or public experiments.

## Security concerns

The public package contains no APKs, DEX files, native libraries, credentials, personal data, victim captures, or directly usable endpoints. The hashes support sample lookup only through authorized malware-sharing platforms.

When using the optional extractor:

1. obtain institutional approval and authorization to possess the sample;
2. use a disposable VM without credentials and preferably without network access;
3. do not install or execute the APK;
4. do not manually open extracted files on the host system;
5. treat everything under `analysis-output/` as potentially sensitive;
6. review and sanitize results before publication; and
7. do not commit APKs, DEX files, decompiled code, or raw indicators.

Parsing and decompilation tools process hostile input and may themselves contain vulnerabilities. Keep them updated and restricted to the isolated environment. The `.gitignore` file blocks executable formats and the default output directory as an additional safeguard, but it does not replace manual review.

## Installation

Clone the repository and enter its root directory:

```bash
git clone https://github.com/renandamasceno/android-maas-brazil-replication-package.git
cd android-maas-brazil-replication-package
```

Confirm the Python version:

```bash
python3 --version
```

There is no build step and no Python-package installation. For an immutable evaluation snapshot, prefer the archive associated with the DOI shown at the beginning of this README.

## Minimum test

Run from the repository root:

```bash
python3 scripts/validate_package.py
```

Expected duration: less than 5 seconds. Expected resources: less than 100 MB of RAM and less than 10 MB of additional disk space. No network access occurs.

Expected output:

```text
Validation passed: 6 samples, 3 secondary payloads, 9 sanitized infrastructure entries.
```

The command returns status code `0` on success. On failure, it returns a nonzero status and reports the detected inconsistencies.

## Experiments

The following experiments operate exclusively on public metadata. Run them from the repository root after installation.

### Claim #1 — Public sample inventory

**Objective.** Confirm that the package contains six unique primary identifiers, all recorded as statically and dynamically analyzed, and three secondary payloads associated with S1.

**Command.**

```bash
python3 scripts/summarize_package.py
```

**Time and resources.** Less than 5 seconds, less than 100 MB of RAM, and no network access.

**Expected result.** The output must report `primary_samples: 6`, `static_analysis_samples: 6`, `dynamic_analysis_samples: 6`, `secondary_payloads: 3`, and `secondary_source_samples: S1`.

The source records are in `data/sample_manifest.csv` and `data/secondary_payloads.csv`; field definitions are in `data/README.md`.

### Claim #2 — Published sanitized infrastructure

**Objective.** Confirm the publication of nine representative sanitized indicators covering all six samples, without URL schemes or apparent credential material.

**Commands.**

```bash
python3 scripts/validate_package.py
python3 scripts/summarize_package.py --format json
```

**Time and resources.** Less than 5 seconds, less than 100 MB of RAM, and no network access.

**Expected result.** Validation must pass; the JSON output must contain `"sanitized_infrastructure_entries": 9` and `"infrastructure_sample_coverage": 6`.

### Claim #3 — Methodological traceability

**Objective.** Support inspection of the path from discovery and selection through acquisition, analysis, and correlation, including the study limitations.

**Procedure.** Read the following documents in order:

1. `queries/osint_queries.md` — representative query and responsible use;
2. `methodology/inclusion_exclusion_criteria.md` — selection and representativeness;
3. `methodology/acquisition_protocol.md` — acquisition and preservation;
4. `methodology/analysis_environment.md` — hardware and tool versions; and
5. `methodology/analysis_workflow.md` — analysis and correlation.

**Expected result.** The documents must use stable identifiers `S1`–`S6`, distinguish static from dynamic analysis, and state that technical correlation does not constitute actor attribution.

### Claim #4 — Optional static extraction with an authorized sample

This experiment is not required for the minimum test and cannot run without a sample legally obtained by the evaluator.

```bash
bash scripts/extract_android_iocs.sh --help
bash scripts/extract_android_iocs.sh /authorized/path/sample.apk analysis-output
```

The first command only displays help. The second should create `analysis-output/<sample-name>/` containing hashes, an inventory, extracted DEX files, and triage outputs. When available, APKTool produces a decoded manifest, resources, and Smali under `apktool/`, while JADX produces an approximate Java representation under `jadx/sources/`. Additional manifest and permission extraction depends on AAPT or APK Analyzer. The results are leads for human review, not automated verdicts.

## Reproducibility limitations

The package supports verification of artifact identification, published relationships, sanitized indicators, and the methodological procedure. It does not permit complete replay of historical dynamic behavior: infrastructure, backend state, campaign availability, device state, and remote triggers may change. A current network failure does not invalidate a hash or a historical observation.

The six samples form a purposive exploratory set and are not statistically representative. Dynamic-analysis coverage varied with exposed behavior and infrastructure availability. The package does not support claims about prevalence, seasonality, or definitive actor attribution.

## LICENSE

The documentation, metadata, and scripts in this repository are licensed under the [Creative Commons Attribution 4.0 International License](LICENSE). See [`CITATION.cff`](CITATION.cff) for citation metadata and the [Zenodo record](https://doi.org/10.5281/zenodo.21767014) for the archived version.
