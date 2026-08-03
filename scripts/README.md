# Scripts

The original investigation was predominantly manual. It combined analyst-driven OSINT triage, victim-flow reproduction, static reverse engineering, physical-device execution, traffic inspection, and cross-sample correlation. No automated end-to-end analysis pipeline is claimed.

`validate_package.py` validates the public package metadata; it does not analyze malware and does not contact any external service.

Run it from the repository root:

```bash
python3 scripts/validate_package.py
```

The script requires Python 3.9 or later and only the standard library.
