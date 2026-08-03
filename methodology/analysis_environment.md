# Analysis Environment

## Physical device

- Device: Samsung Galaxy A32
- Operating system: Android 13
- Root framework: Magisk 30.7
- Execution model: manual, controlled execution on a physical device
- Network monitoring: Burp Suite through a controlled proxy
- Real user accounts: not used
- Production credentials: not used

A physical device was used instead of an automated sandbox or emulator to reduce the impact of emulator-detection mechanisms and to reproduce victim-facing installation and interaction workflows more closely.

## Session isolation

Between analysis sessions, the analyzed application and any additional packages associated with staged or secondary payloads were uninstalled through ADB together with their application-specific data. The device was not factory-reset between sessions.

The paper does not report a uniform number of executions per sample. Each sample was manually exercised through the behavior available during observation. Execution duration varied according to the behavior exposed by each sample and the availability of its remote infrastructure.

## Static-analysis tools

- JADX 1.5.5
- apktool 2.7.0-dirty
- MobSF 4.5.0

## Static-analysis targets

- `AndroidManifest.xml`, permissions, services, receivers, and exposed components
- Accessibility Service implementations
- WebView usage
- hardcoded URLs and other network indicators
- encoded or obfuscated strings
- DEX files and source-level behavior
- native components
- dynamically delivered artifacts

When automated decompilation was impaired by obfuscation, malformed archive structures, native components, or staged delivery, APK contents were manually extracted and DEX artifacts inspected separately.

## Dynamic-analysis targets

- installation and startup behavior
- permission requests and Accessibility Service activation flows
- WebView interactions
- background execution
- network requests, responses, and command semantics
- downloaded or split-package payloads
- backend-triggered behavior

Retrieved secondary artifacts were analyzed separately and identified by SHA-256. Their public filenames and digests are recorded in `data/secondary_payloads.csv`; the executable artifacts themselves are not distributed.
