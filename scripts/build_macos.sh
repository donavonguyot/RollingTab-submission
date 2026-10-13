#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/toolchain.sh
flutter pub get
# The caller must close the old app first. Xcode incremental embedding can retain
# frameworks from removed plugins, so rebuild the application bundle itself.
python3 - <<'PYCHECK'
from pathlib import Path
import subprocess,shutil
app=Path('build/macos/Build/Products/Release/RollingTAB.app').resolve()
for line in subprocess.check_output(['ps','-axo','comm='],text=True).splitlines():
 if line.strip()==str(app/'Contents/MacOS/RollingTAB'):raise SystemExit('Close the running review app before rebuilding it.')
if app.exists():shutil.rmtree(app)
PYCHECK
flutter build macos --release "$@"

python3 scripts/check_audio_package.py build/macos/Build/Products/Release/RollingTAB.app
