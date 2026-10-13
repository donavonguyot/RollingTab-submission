#!/usr/bin/env bash
# Source from bash. Use the pinned SDK already installed by the developer.
if [[ -n "${ROLLINGTAB_FLUTTER_ROOT:-}" ]]; then
  export FLUTTER_ROOT="$ROLLINGTAB_FLUTTER_ROOT"
else
  rollingtab_flutter="$(command -v flutter || true)"
  [[ -n "$rollingtab_flutter" ]] || { echo 'Install Flutter 3.47.6 and set ROLLINGTAB_FLUTTER_ROOT to its SDK directory.'; return 1; }
  export FLUTTER_ROOT="$(python3 - "$rollingtab_flutter" <<'PYROOT'
from pathlib import Path
import sys
print(Path(sys.argv[1]).resolve().parent.parent)
PYROOT
)"
fi
export PATH="$FLUTTER_ROOT/bin:$PATH"
[[ -x "$FLUTTER_ROOT/bin/flutter" ]] || { echo 'ROLLINGTAB_FLUTTER_ROOT must contain bin/flutter.'; return 1; }
flutter --version --machine | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["frameworkVersion"]=="3.47.6" and d["dartSdkVersion"].startswith("3.13.5"), "Flutter 3.47.6 / Dart 3.13.5 required"' || return 1
