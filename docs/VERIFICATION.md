# Submission verification — 2026-10-13

## Initial snapshot validation

The initial checks ran against an isolated copy of this snapshot with no original Git history, private configuration, generated outputs or databases. All verification-only secrets, databases, logs and builds stayed outside the delivered source directory/archive.

### Passed

- Dependency installation using Flutter 3.47.6 / Dart 3.13.5 and locked Serverpod 4.0.3 / Jaspr 0.23.5 packages.
- Jaspr static homepage, Flutter release Wasm and native-hook Serverpod executable builds; web staging and obsolete-audio-asset checks.
- Clean Flutter, server and site analysis; **49 Flutter tests and nine server tests**. Test expectations match the five-score submission collection.
- Isolated live backend: exactly five scores, compressed/logical score hashes, unknown-download denial, homepage/app routes, isolation headers, asset MIME types and video ranges.
- Disposable local invited accounts: login, cookie refresh, sign-out revocation, anonymous-write denial, account ownership, retry-safe saves, revision conflicts, rename/delete and persistence across save/list requests at supported speeds.
- Relative Markdown links, shell/Python syntax, source-only archive inventory, and included asset/provenance hashes.
- Snapshot pattern audit found no absolute original-machine paths, sibling-project inventories, old backend endpoints, known historical development passwords, private-key blocks or recognized provider-token shapes. This is a scoped audit, not a guarantee against every possible secret.

### Validation conditions

The original local ports were reserved for existing services. The temporary validation copy used API/Insights/web ports 29993/29994/29995 and embedded PostgreSQL 54349; its config was restored afterward and its owned server stopped. The delivered defaults remain 9893/9894/9895 and 54339. No original service was stopped or production deployment changed.

First-pass analysis before a Flutter build reported missing generated shader asset directories; the documented build sequence generates them. Analysis after build/tests passed. A catalog test still expecting the seven-score development collection was corrected for this five-score snapshot before the passing run.

These are build, unit/integration and HTTP protocol checks. They do not claim a new browser audio/visual acceptance trial or native application release build. Dedicated hosted judge-account sign-in and browser save → reload → reopen remain pending. No repository upload, judge invitation, demo-video publication or contest submission occurred.

### Distribution

The archive includes source, tests, lockfiles, five approved score artifacts, SoundFont/media assets, required licenses, compact provenance, and build/judge instructions. It excludes Git history, local secrets, databases, generated builds, raw review evidence, sibling baseline inventories, source-harvesting snapshots, old integration patches and production deployment controls.

The original working files, Git HEAD, refs and pre-existing working-tree changes were preserved. Required adapted decoder/audio code, compatibility identifiers, public branding and truthful component attribution remain present.

## Self-service authentication update

The submission repository now includes Serverpod email signup and password reset with Resend delivery. Domain verification and DNS records for `mail.rollingtab.com` passed. Production credentials remain outside source. Local end-to-end verification used ports 29993–29995 and PostgreSQL 54349 without stopping existing services.

- Flutter: 53 tests passed; the four new auth tests cover scalar protocol results, structured errors, signup/password validation, reset navigation and disabled controls.
- Server: 19 tests passed. Auth tests cover signup, reset, revoked refresh tokens, generic duplicate/unknown email responses, failed delivery, expiry, exhausted/reused/replaced codes, password policy, concurrent requests and send budgets. Existing catalog and ownership tests remain passing.
- Resend reported delivery to the authorized test inbox; local HTTP signup, cookie refresh and saved passage persistence at 73% with loop enabled passed.
- Jaspr, Flutter Wasm and native-hook server builds passed. Route/media/header checks and all five score hashes passed. Browser inspection confirmed the new sign-in/signup/reset controls render correctly.
- Hosted rollout and final browser acceptance are recorded after execution; local results alone do not establish hosted completion.
- The integration suites share configured ports; `dart_test.yaml` serializes test files to avoid intermittent bind conflicts.
