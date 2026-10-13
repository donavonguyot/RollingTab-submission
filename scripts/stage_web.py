#!/usr/bin/env python3
"""Stage the built Flutter release in the independent server's web root."""
import shutil
from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=root/'build/web';destination=root/'rollingtab_server/web/app'
site=root/'rollingtab_site/build/jaspr';site_destination=root/'rollingtab_server/web/site'
if not (site/'index.html').exists():raise SystemExit('Build the Jaspr homepage with scripts/build_site.sh first.')
if not (source/'main.dart.wasm').exists():
 raise SystemExit('Build the Wasm app first.')
if destination.exists():shutil.rmtree(destination)
shutil.copytree(source,destination,ignore=shutil.ignore_patterns('*.map'))
print('Staged Flutter Wasm app with continuous Web Audio.')

if site_destination.exists():shutil.rmtree(site_destination)
# Jaspr's build tree also contains dependency/build metadata. This page needs
# only its generated document and explicitly owned public assets.
site_destination.mkdir()
shutil.copy2(site/'index.html',site_destination/'index.html')
shutil.copytree(site/'site-assets',site_destination/'site-assets')
print('Staged static Jaspr homepage.')
