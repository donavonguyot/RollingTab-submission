#!/usr/bin/env python3
"""Reject obsolete playback artifacts in a built web or macOS application."""
import argparse,json,pathlib
p=argparse.ArgumentParser();p.add_argument('path');a=p.parse_args();root=pathlib.Path(a.path)
assert root.is_dir(), 'Build output missing'
files=[x for x in root.rglob('*') if x.is_file()]
obsolete=[str(x.relative_to(root)) for x in files if 'soloud' in str(x).lower() or 'audio_worker' in x.name or '/assets/audio/' in str(x)]
assert not obsolete, 'Obsolete playback artifacts: '+str(obsolete)
print(json.dumps({'path':str(root),'files':len(files),'obsoletePlaybackArtifacts':obsolete}))
