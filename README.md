# Android MaaS Brazil Replication Package

This repository accompanies the paper:

> **Characterizing Malware-as-a-Service-Oriented Android Fraud Campaigns Targeting Brazil**
>
> José Renan F. Damasceno, Carlos Adriel Sousa Bastos, Francisco Lucas Falcão Pereira, Emanuel Bezerra Rodrigues, and Paulo Antonio Leal Rego.

## Contents

The package provides:

- SHA-256 identifiers and high-level metadata for the six analyzed samples;
- SHA-256 identifiers for the secondary split-package artifacts delivered by S1;
- representative, sanitized infrastructure indicators;
- documented acquisition, selection, static-analysis, dynamic-analysis, and correlation procedures;
- the analysis-environment specification;
- a representative OSINT query; and
- a local consistency validator for the published metadata.

## Repository structure

```text
.
|-- CITATION.cff
|-- LICENSE
|-- README.md
|-- data/
|   |-- README.md
|   |-- sample_manifest.csv
|   |-- sanitized_infrastructure.csv
|   `-- secondary_payloads.csv
|-- methodology/
|   |-- acquisition_protocol.md
|   |-- analysis_environment.md
|   |-- analysis_workflow.md
|   `-- inclusion_exclusion_criteria.md
|-- queries/
|   `-- osint_queries.md
`-- scripts/
    |-- README.md
    `-- validate_package.py
```

## Malware binaries

Executable malware samples are not publicly distributed because of operational, ethical, and security risks. This repository contains cryptographic hashes and sanitized metadata that can be used to identify the analyzed artifacts through authorized malware-sharing platforms.

Do not submit credentials, tokens, victim data, personal information, live operational endpoints, or directly usable executables to this repository.

## Reproducibility scope

The package supports reproduction of the artifact-identification, infrastructure-analysis, and methodological procedures described in the paper. Exact dynamic behavior may vary because remote infrastructure, backend state, campaign availability, device state, and remote triggers can change over time.

The six artifacts form a purposive exploratory sample. They are not statistically representative of the Brazilian Android malware ecosystem. Dynamic-analysis coverage also varied according to the behavior exposed by each sample and the availability of its remote infrastructure.

## Quick validation

The validator uses only the Python standard library:

```bash
python3 scripts/validate_package.py
```

It checks CSV schemas, sample references, SHA-256 formatting and uniqueness, Boolean fields, collection-window formatting, and basic indicator sanitization.

## Citation

Please use the metadata in [`CITATION.cff`](CITATION.cff). A DOI can be added after the first archival release is deposited in Zenodo.

## License

The documentation and metadata in this repository are licensed under the [Creative Commons Attribution 4.0 International License](LICENSE).
