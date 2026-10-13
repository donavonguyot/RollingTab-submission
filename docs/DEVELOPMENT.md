# Build and verify from source

Verified target: macOS with Chrome for the web app; macOS native is optional. Install Flutter **3.47.6**, which supplies Dart **3.13.5**, plus Python 3 and Xcode/command-line tools for native dependencies. Dependency downloads require internet access. Use bash for the command blocks. Point `ROLLINGTAB_FLUTTER_ROOT` at your Flutter SDK directory, or put the pinned Flutter on PATH. Scripts check the version and do not upgrade it. Serverpod packages are pinned at **4.0.3**; generated models/client are included, so its CLI is optional for development changes only.

From the extracted repository root:

```bash
export ROLLINGTAB_FLUTTER_ROOT=/absolute/path/to/flutter-3.47.6
source scripts/toolchain.sh
flutter pub get
(cd rollingtab_server && dart pub get --enforce-lockfile)
python3 scripts/setup_backend.py
scripts/build_site.sh
scripts/build_web.sh
python3 scripts/stage_web.py
scripts/build_server.sh
python3 scripts/backend.py start
```

The setup script generates fresh local development/test secrets in ignored `rollingtab_server/config/passwords.yaml` with mode 0600 and preserves existing secrets. The runner uses API 9893, Insights 9894, web 9895 and embedded PostgreSQL 54339. It imports exactly the five bundled scores and applies its own migrations. If ports are occupied it refuses startup: do not terminate another service. Use a separate environment with those ports free. Open http://localhost:9895/ or http://localhost:9895/play/ in Chrome. Press Play to enable audio.

`python3 scripts/backend.py status`, `stop`, and `restart` operate only this checkout's recorded process group. PostgreSQL data persists in ignored `rollingtab_server/.serverpod/development/pgdata`; do not delete it to restart.

## Analysis and tests

```bash
source scripts/toolchain.sh
flutter analyze
flutter test
(cd rollingtab_server && dart analyze && dart test)
(cd rollingtab_site && dart analyze)
python3 scripts/check_audio_package.py build/web
```

Server tests use the separate test database on port 54340. The repertoire tests exercise only the five bundled scores. The score-projection diagnostic goes to the system temporary directory; no historical review files are required.

With the local backend running:

```bash
python3 scripts/check_site.py
python3 scripts/check_repertoire.py
```

These checks write ignored local reports under `.private/`. `ROLLINGTAB_VERIFY_BASE` may select a confirmed hosted URL for read-only route/score checks. Credentials and databases are not included in this snapshot.

## Optional local invited accounts

Create a private JSON file outside Git containing two independent local accounts for ownership testing:

```json
[{"email":"first@example.com","password":"REPLACE_WITH_UNIQUE_PASSWORD_16_CHARS_MIN"},{"email":"second@example.com","password":"REPLACE_WITH_DIFFERENT_PRIVATE_PASSWORD"}]
```

Restrict its permissions to 0600. Run `python3 scripts/provision_local.py /absolute/private/accounts.json` after building/staging. It temporarily provisions the local accounts, verifies login, removes the bootstrap secret and restarts the owned runner. Existing passwords are never reset. These are disposable local accounts, not judge or production accounts.

```bash
ROLLINGTAB_VERIFY_ACCOUNTS=/absolute/private/accounts.json python3 scripts/check_backend.py
```

This check creates and deletes its own passages and verifies ownership, cookie refresh, retries, revision handling and sign-out. Never run it against an unrelated service.

## Optional native build

Close a running app at the output path, then run `scripts/build_macos.sh` and open `build/macos/Build/Products/Release/RollingTAB.app`. It uses the local API/web addresses. A Cloud-connected build can be created with:

```bash
scripts/build_macos.sh --dart-define=ROLLINGTAB_API_BASE=https://rollingtab.api.serverpod.space/ --dart-define=ROLLINGTAB_WEB_BASE=https://rollingtab.serverpod.space/
```

Builds use the normal production interface without enabling evidence controls. Deployment operations and production secrets are intentionally outside this source handoff.

## Optional self-service signup and recovery

The default build supports guest practice and existing-account login without Resend credentials. To enable signup/reset, create a sending-only Resend key scoped to your verified domain, add `resendApiKey` under the applicable mode in ignored `rollingtab_server/config/passwords.yaml`, and start the server with:

```sh
export ROLLINGTAB_SELF_SERVICE_AUTH_ENABLED=true
export ROLLINGTAB_EMAIL_FROM='RollingTAB <noreply@mail.your-domain.example>'
```

Use your own verified sender. The hosted sender is `RollingTAB <noreply@mail.rollingtab.com>`. Never commit the key. Tests inject an in-memory sender; no emails are sent by `dart test`. The additive migration creates a send-budget table; it does not replace account or passage data. Limits are one request per email per minute, three per hour, and 100 globally per hour, shared across signup/reset and enforced on direct API requests too. Failed sends consume a slot. New requests invalidate the previous registration code.

After endpoint/model changes, use Serverpod CLI 4.0.3 from `rollingtab_server` to run `serverpod generate`; run `serverpod create-migration` only when the schema changes. Generated clients and migrations are committed for ordinary fresh-checkout builds.

Production uses the existing Serverpod Cloud project and authentication secrets. Configure the new sender and secret, deploy with self-service disabled for the initial route checks, then enable and redeploy for acceptance. If acceptance fails, set the flag false and redeploy or restore the previous compatible code package; keep the additive table and existing authentication secrets. Monitor sanitized authentication-email failures and Resend delivery events. SMTP, marketing emails, receiving email, and email tracking are not used.
