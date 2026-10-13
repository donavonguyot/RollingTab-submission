#!/usr/bin/env python3
"""Operate only RollingTAB's recorded development runner and process group."""
import argparse,json,os,signal,subprocess,time,urllib.request
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
STATE=ROOT/'.private/backend-runner.json'
LOG=ROOT/'.private/backend.log'

def alive(state):
 try:
  group=int(subprocess.check_output(['ps','-p',str(state['pid']),'-o','pgid='],text=True).strip())
  started=subprocess.check_output(['ps','-p',str(state['pid']),'-o','lstart='],text=True).strip()
  return group==state['pid'] and started==state['started']
 except subprocess.CalledProcessError:return False

def group_active(pid):
 rows=subprocess.check_output(['ps','-axo','pgid=,stat='],text=True).splitlines()
 return any(int(row.split()[0])==pid and not row.split()[1].startswith('Z') for row in rows if row.split())

def stop():
 if not STATE.exists():return
 state=json.loads(STATE.read_text())
 if alive(state):
  os.killpg(state['pid'],signal.SIGTERM)
  for _ in range(100):
   if not group_active(state['pid']):break
   time.sleep(.1)
  if group_active(state['pid']):raise SystemExit('Runner process group has not stopped; inspect it before retrying.')
 STATE.unlink(missing_ok=True)

def start():
 if STATE.exists() and alive(json.loads(STATE.read_text())):raise SystemExit('RollingTAB runner already active.')
 ROOT.joinpath('.private').mkdir(exist_ok=True)
 with LOG.open('ab') as log:
  p=subprocess.Popen([str(ROOT/'scripts/start_backend.sh')],cwd=ROOT,stdout=log,stderr=log,stdin=subprocess.DEVNULL,start_new_session=True)
 time.sleep(.5)
 if p.poll() is not None:raise SystemExit('Runner exited; see .private/backend.log')
 state={'pid':p.pid,'command':subprocess.check_output(['ps','-p',str(p.pid),'-o','command='],text=True).strip(),'started':subprocess.check_output(['ps','-p',str(p.pid),'-o','lstart='],text=True).strip()}
 STATE.write_text(json.dumps(state));STATE.chmod(0o600)
 for _ in range(120):
  if p.poll() is not None:raise SystemExit('Runner exited; see .private/backend.log')
  try:
   req=urllib.request.Request('http://localhost:9893/catalog/list',data=b'{}',headers={'Content-Type':'application/json'})
   if json.load(urllib.request.urlopen(req,timeout=1)):
    print('RollingTAB homepage: http://localhost:9895 | Practice: http://localhost:9895/play/');return
  except Exception:pass
  time.sleep(.5)
 raise SystemExit('Startup timed out; inspect .private/backend.log')

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('command',choices=['start','stop','restart','status']);a=p.parse_args()
 if a.command in ['stop','restart']:stop()
 if a.command in ['start','restart']:start()
 if a.command=='status':print('running' if STATE.exists() and alive(json.loads(STATE.read_text())) else 'not owned/running')
