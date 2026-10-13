#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/toolchain.sh"
cd "$root/rollingtab_server"
dart pub get
dart build cli --target bin/main.dart --output "$root/build/server"
