#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/toolchain.sh
cd rollingtab_site
dart pub get --enforce-lockfile
dart run jaspr_cli:jaspr --disable-analytics
dart run jaspr_cli:jaspr build
