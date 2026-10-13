#!/usr/bin/env python3
"""Provision invited local accounts from a private JSON file, then remove the bootstrap secret."""
import argparse,json,subprocess,time,urllib.request
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('accounts',type=Path);args=p.parse_args()
accounts=json.loads(args.accounts.read_text())
assert isinstance(accounts,list) and accounts
assert all(isinstance(a,dict) and '@' in a['email'] and len(a['password'])>=16 for a in accounts)
subprocess.run(['python3',str(ROOT/'scripts/setup_backend.py')],check=True)
config=ROOT/'rollingtab_server/config/passwords.yaml'
text=config.read_text()
if 'bootstrapAccounts:' in text:raise SystemExit('A bootstrap secret already exists; inspect it before replacing it.')
secret='  bootstrapAccounts: '+json.dumps(json.dumps(accounts))+'\n'
assert '\ndevelopment:\n' in '\n'+text
config.write_text(text.replace('development:\n','development:\n'+secret,1));config.chmod(0o600)
try:
 subprocess.run(['python3',str(ROOT/'scripts/backend.py'),'restart'],check=True)
 for account in accounts:
  # Startup provisions asynchronously after the listener opens. Retry briefly.
  for attempt in range(20):
   try:
    request=urllib.request.Request('http://localhost:9893/emailIdp/login',data=json.dumps(account).encode(),headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(request,timeout=10) as response:auth=json.load(response)
    break
   except Exception:
    if attempt==19:raise SystemExit('Provisioning/login not verified. Existing passwords are never reset; inspect the private backend log.')
    time.sleep(.25)
  request=urllib.request.Request('http://localhost:9893/serverpod_auth_core.status/signOutDevice',data=b'{}',headers={'Content-Type':'application/json','Authorization':'Bearer '+auth['token']})
  urllib.request.urlopen(request,timeout=10).close()
 print('Invited accounts verified; existing passwords were not reset.')
finally:
 current=config.read_text()
 if secret in current:config.write_text(current.replace(secret,''));config.chmod(0o600)
 subprocess.run(['python3',str(ROOT/'scripts/backend.py'),'restart'],check=True)
 print('Bootstrap secret removed from local server configuration.')
