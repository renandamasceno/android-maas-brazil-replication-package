# Acquisition Protocol

1. Search for suspicious Android distribution infrastructure using OSINT-oriented queries in Shodan.
2. Perform complementary checks in urlscan.io.
3. Manually inspect candidate pages for PT-BR content, Brazilian-facing lures, and deceptive Android distribution interfaces resembling Google Play.
4. Triage candidates using the criteria in [`inclusion_exclusion_criteria.md`](inclusion_exclusion_criteria.md).
5. Reproduce the victim-facing download workflow in a controlled laboratory environment to acquire the APK and preserve relevant operational context.
6. Compute a SHA-256 digest for each acquired first-stage APK and any dynamically delivered artifacts.
7. Execute artifacts only on the isolated analysis device described in [`analysis_environment.md`](analysis_environment.md).
8. Record delivery behavior, visible runtime behavior, network observations, and retrieved secondary artifacts.

The paper reports a study-level collection window of March-May 2026, but does not provide an exact acquisition date for each sample. The manifest therefore records the common ISO 8601 interval `2026-03/2026-05`; it does not infer per-sample dates.

## Safety and ethics

- Do not use personal or production accounts.
- Do not enter real credentials, payment-card information, or victim data.
- Do not interact with victims or perform operational fraud activity.
- Do not publish directly usable malware binaries or live, unsanitized endpoints.
- Treat infrastructure observations as historical and potentially reassigned.
