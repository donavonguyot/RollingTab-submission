#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/toolchain.sh
flutter pub get
python3 -c "import shutil; shutil.rmtree('build/web', ignore_errors=True)"
flutter build web --wasm --release --base-href=/play/ "$@"

python3 - "$@" <<'PYBUILD'
import json,pathlib,subprocess,sys
pathlib.Path('build/web/rollingtab-build.json').write_text(json.dumps({
 'sourceCommit':'submission-snapshot',
 'flutter':'3.47.6','dart':'3.13.5','mode':'release-wasm','baseHref':'/play/',
 'reviewEnabled':any('ROLLINGTAB_EVIDENCE=true' in x or 'ROLLINGTAB_CONTROL_PORT=' in x for x in sys.argv[1:])
},indent=2)+'\n')
PYBUILD
