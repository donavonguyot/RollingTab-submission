#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/rollingtab_server"
python3 - <<'PY'
import socket
for port in (9893,9894,9895):
 for family,host in ((socket.AF_INET,'127.0.0.1'),(socket.AF_INET6,'::')):
  s=socket.socket(family)
  try:
   if family==socket.AF_INET6:s.setsockopt(socket.IPPROTO_IPV6,socket.IPV6_V6ONLY,1)
   s.bind((host,port))
  except OSError: raise SystemExit(f'Port {port} is occupied; refusing to stop another process.')
  finally: s.close()
PY
source "$root/scripts/toolchain.sh"
# The CLI development VM injects a polling script into HTML. A direct launch
# keeps the static homepage script-free and still uses Serverpod's embedded DB.
exec "$FLUTTER_ROOT/bin/dart" run bin/main.dart --apply-migrations
