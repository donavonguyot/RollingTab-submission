#!/usr/bin/env python3
"""Create fresh local secrets; never overwrite existing configuration."""
from pathlib import Path
import secrets,json
root=Path(__file__).resolve().parents[1]
p=root/'rollingtab_server/config/passwords.yaml'
if not p.exists():
 text=''
 for mode in ['development','test']:
  text+=mode+':\n'
  for key in ['database','serviceSecret','emailSecretHashPepper','jwtHmacSha512PrivateKey','jwtRefreshTokenHashPepper']:
   text+=f'  {key}: "{secrets.token_urlsafe(48)}"\n'
 p.write_text(text)
p.chmod(0o600)
print('Local secrets ready; existing values preserved.')
