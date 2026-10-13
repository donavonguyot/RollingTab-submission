# RollingTAB

Practice a guitar passage with audible playback, moving Perspective TAB, and a Now + next view of current and upcoming string positions. Slow playback without changing pitch, loop a difficult passage, and save its settings for next time.

[Live homepage](https://rollingtab.serverpod.space/) · [Play in Chrome](https://rollingtab.serverpod.space/play/) · [Judge walkthrough](docs/JUDGE_GUIDE.md)

## What is included

- Guest practice without sign-in; invited accounts save named passages.
- Five scores matching the published collection: Paganini, Carulli Vals, Carcassi No. 11, Bach Bourrée, and Carulli La sautillante, plus authored studies.
- Pitch-preserving speed from 25–150%, passage loops up to 60 score seconds, left-handed fretboards, light/dark appearance and reduced motion.
- Source TAB is labeled separately from inferred string/fret guidance. Positions are expected positions, not detected fingers. Recognition, public registration and uploads are outside this submission.

## How it works

Flutter renders the practice interface and synthesizes SoundFont audio locally. Serverpod supplies the catalog and immutable score bytes, authenticates invited accounts, and stores each account's saved passages in PostgreSQL. Serverpod Cloud hosts the public demo. The local backend owns its own database and requires no sibling application.

## Build and judge

Use Chrome for the hosted walkthrough. For a local build, follow [Development](docs/DEVELOPMENT.md): Flutter **3.47.6 / Dart 3.13.5**, the locked Serverpod **4.0.3** packages, Python 3, and macOS with Xcode for native builds. Source archives work without Git history. The generated client is included, so Serverpod CLI/code generation is not required for an ordinary build.

```bash
export ROLLINGTAB_FLUTTER_ROOT=/absolute/path/to/flutter-3.47.6
source scripts/toolchain.sh
flutter pub get
(cd rollingtab_server && dart pub get --enforce-lockfile)
python3 scripts/setup_backend.py
scripts/build_site.sh
scripts/build_web.sh
python3 scripts/stage_web.py
python3 scripts/backend.py start
```

Open http://localhost:9895/play/ and press Play to enable audio. Existing services must not occupy the documented ports. Initial audio loading downloads the approximately 31 MB SoundFont. See [Development](docs/DEVELOPMENT.md) for tests, local accounts and optional macOS builds.

## Submission status and attribution

[Submission handoff](docs/SUBMISSION_HANDOFF.md) lists the remaining private repository, judge-access and video steps. [Verification](docs/VERIFICATION.md) distinguishes executed checks from pending acceptance. This source snapshot is separate from the author's development repository and contains no earlier Git history, raw internal review logs or sibling-project inventories.

[Attribution](THIRD_PARTY.md) and [score credits](rollingtab_server/assets/scores/SOURCE_CREDITS.md) retain component origins and third-party licenses. The repository is supplied for private judging; no project-wide open-source license is granted.
