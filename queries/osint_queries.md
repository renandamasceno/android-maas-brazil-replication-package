# Representative OSINT Queries

## Shodan

```text
http.title:"Google Play" country:BR
```

In the study period, this representative query returned more than 20 candidate web endpoints for manual inspection. Search results are time-dependent and may include benign or unrelated infrastructure. A match is a discovery lead, not evidence of maliciousness.

## Complementary inspection

Candidate endpoints were checked in urlscan.io and manually inspected for PT-BR content, Brazilian-facing lures, deceptive Google Play-style delivery, and an associated victim-facing APK workflow.

## Responsible use

- Do not download or execute artifacts outside an isolated laboratory.
- Do not submit credentials or personal information to candidate pages.
- Do not treat a search match as a verdict.
- Follow platform terms, applicable law, and institutional ethics requirements.
- Avoid active interaction that could disrupt infrastructure or affect third parties.
