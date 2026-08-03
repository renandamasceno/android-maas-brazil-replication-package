# Data Dictionary

All files use UTF-8 encoding, comma delimiters, a single header row, and Unix line endings. No malware binaries, victim data, credentials, or unsanitized operational endpoints are included.

## `sample_manifest.csv`

| Field | Description |
| --- | --- |
| `sample_id` | Stable anonymized identifier used in the paper (`S1`-`S6`). |
| `sha256` | Lowercase SHA-256 digest of the analyzed first-stage APK. |
| `collection_window` | Study-level collection window represented as an ISO 8601 interval. The paper reports only March-May 2026, not an exact date for each sample. |
| `lure_theme` | High-level lure description reported in Appendix A. |
| `delivery_method` | Victim-facing delivery mechanism observed across the sample set. |
| `static_analysis` | Whether the sample was included in the static-analysis workflow. |
| `dynamic_analysis` | Whether the sample was included in the dynamic-analysis workflow. Coverage varied by sample and infrastructure availability. |

## `secondary_payloads.csv`

| Field | Description |
| --- | --- |
| `source_sample` | First-stage sample that delivered the artifact. |
| `artifact` | Filename of the retrieved split-package artifact. |
| `sha256` | Lowercase SHA-256 digest of the retrieved artifact. |

## `sanitized_infrastructure.csv`

| Field | Description |
| --- | --- |
| `sample_id` | Sample associated with the representative infrastructure artifact. |
| `artifact_type` | Either `domain` or `domain_pattern`. |
| `sanitized_value` | Defanged representative value. `[.]` replaces at least one operational dot; `*` denotes a rotating subdomain component rather than a literal host. |

The infrastructure file is intended for research correlation, not automated blocking. Entries are representative historical observations and may later be reassigned, sinkholed, or become benign.
