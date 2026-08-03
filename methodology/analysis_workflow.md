# Analysis Workflow

The study used a campaign-oriented workflow that connected delivery infrastructure to Android behavior and cross-sample operational evidence.

## 1. Infrastructure discovery

Discover candidate delivery endpoints through OSINT searches and complementary historical checks. Manually screen each endpoint for localized social engineering, deceptive distribution behavior, and an associated Android artifact.

## 2. APK acquisition

Reproduce the victim-facing download path in the controlled laboratory. Hash the acquired APK with SHA-256 and assign the stable paper identifier (`S1`-`S6`).

## 3. Parallel technical analysis

### Dynamic analysis

Install one sample at a time on the physical device. Exercise the available flow, including permission prompts, Accessibility Service prompts, WebViews, staged downloads, and background behavior. Route traffic through Burp Suite and record contacted endpoints, request/response semantics, downloaded artifacts, and visible effects.

### Static reverse engineering

Inspect the manifest, permissions, components, DEX code, strings, URLs, Accessibility Services, WebViews, native components, and fraud-related indicators with JADX, apktool, and MobSF. If standard decompilation fails, manually extract the archive and inspect DEX artifacts separately.

### Artifact extraction

Identify first-stage and secondary artifacts by SHA-256. Extract representative infrastructure indicators and sanitize them before publication.

## 4. Campaign correlation

Correlate findings across these dimensions:

- phishing-page and delivery-page structure;
- APK sideloading and staged-delivery mechanisms;
- lure theme and PT-BR localization;
- WebView, Accessibility Service, and overlay-oriented behavior;
- network paths, response semantics, and command-and-control behavior; and
- obfuscation, malformed archives, split packages, and other anti-analysis mechanisms.

Treat shared behavior as evidence of technical or operational relatedness, not definitive actor attribution.

## 5. Operational characterization

Synthesize the correlated evidence into the study's exploratory taxonomy: delivery mechanism, social-engineering theme, behavioral capability, infrastructure pattern, and anti-analysis strategy.

## Reproduction limits

Backend state, remote triggers, infrastructure availability, and device state may prevent exact replay of historical dynamic behavior. A failed network response at reproduction time does not invalidate a hash or a previously recorded observation.
