#!/usr/bin/env python3
"""Live verification against RollingTAB only. Never prints account credentials."""
import hashlib,http.cookiejar,json,urllib.request,urllib.error,uuid,os
from pathlib import Path
Path(__file__).resolve().parents[1].joinpath('.private').mkdir(exist_ok=True)
root=Path(__file__).resolve().parents[1]
base='http://localhost:9895'
accounts=json.loads(Path(os.environ.get('ROLLINGTAB_VERIFY_ACCOUNTS',str(root/'.private/local-accounts.json'))).read_text())
base=os.environ.get('ROLLINGTAB_VERIFY_BASE',base).rstrip('/')
report={'base':base}
def call(op,path,data,token=None,expected=200,origin=base):
 headers={'Content-Type':'application/json','Origin':origin,'x-serverpod-auth-mode':'cookie'}
 if token:headers['Authorization']='Bearer '+token
 req=urllib.request.Request(base+'/api/'+path,data=json.dumps(data).encode(),headers=headers)
 try:r=op.open(req)
 except urllib.error.HTTPError as e:r=e
 body=r.read();assert r.code==expected,(path,r.code,body[:300])
 return json.loads(body) if body and expected in (200,400) else None
op=urllib.request.build_opener()
score=next(x for x in call(op,'catalog/list',{}) if x['cid']=='QmcmrMSehjpEW3yzzstiCECCTxLNBapeRrnQKc7rrWCB26')
raw=urllib.request.urlopen(base+score['downloadPath']).read()
assert len(raw)==score['compressedBytes'] and hashlib.sha256(raw).hexdigest()==score['compressedSha256']
report['artifact']={'cid':score['cid'],'sha256':score['compressedSha256'],'bytes':len(raw)}
call(op,'passages/list',{},expected=401)
try:
 urllib.request.urlopen(base+'/api/catalog/list')
 raise AssertionError('GET bridge unexpectedly accepted')
except urllib.error.HTTPError as e:assert e.code==405
for path in ['unrelated/operation']:
 call(op,path,{},expected=403)
call(op,'catalog/list',{},expected=403,origin='https://foreign.invalid')
sessions=[]
for account in accounts:
 jar=http.cookiejar.CookieJar();client=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
 result=call(client,'emailIdp/login',account)
 assert result.get('refreshToken') is None
 assert all('HttpOnly' in c._rest for c in jar)
 if base.startswith('https://'):
  assert len(list(jar))>0
  expected_paths={'rollingtab_auth':'/api/','rollingtab_refresh':'/api/jwtRefresh'}
  assert all(c.secure and c.path==expected_paths.get(c.name) for c in jar)
  report['cookieAttributes']=[{'name':c.name,'secure':c.secure,'path':c.path,'httpOnly':'HttpOnly' in c._rest,'sameSite':c._rest.get('SameSite')} for c in jar]
 result=call(client,'jwtRefresh/refreshAccessToken',{'refreshToken':None})
 sessions.append((client,result['token']))
a,at=sessions[0];b,bt=sessions[1]
p={'passageId':str(uuid.uuid4()),'cid':score['cid'],'artifactVersion':score['artifactVersion'],'sourceSlot':1,'name':'Acceptance passage','start':79.385,'end':109.385,'tempo':.75,'loop':True,'expectedRevision':0,'requestId':str(uuid.uuid4())}
first=call(a,'passages/save',{'input':p},at)
retry=call(a,'passages/save',{'input':p},at)
assert first['id']==retry['id'] and retry['revision']==1
assert all(x['passageId']!=p['passageId'] for x in call(b,'passages/list',{},bt))
# Serialized endpoint exceptions use HTTP 400.
call(b,'passages/save',{'input':p},bt,expected=400)
call(b,'passages/delete',{'passageId':p['passageId'],'expectedRevision':1},bt,expected=400)
p.update(expectedRevision=1,requestId=str(uuid.uuid4()),name='Renamed acceptance passage')
updated=call(a,'passages/save',{'input':p},at);assert updated['revision']==2
call(a,'passages/delete',{'passageId':p['passageId'],'expectedRevision':1},at,expected=400)
call(a,'passages/delete',{'passageId':p['passageId'],'expectedRevision':2},at)
for tempo in [.25,.5,.73,.75,1.0,1.5]:
 p.update(passageId=str(uuid.uuid4()),requestId=str(uuid.uuid4()),expectedRevision=0,tempo=tempo)
 saved=call(a,'passages/save',{'input':p},at)
 reopened=next(x for x in call(a,'passages/list',{},at) if x['passageId']==p['passageId'])
 assert saved['tempo']==tempo and reopened['tempo']==tempo
 call(a,'passages/delete',{'passageId':p['passageId'],'expectedRevision':1},at)
for tempo in [.24,.735,1.51]:
 p.update(passageId=str(uuid.uuid4()),requestId=str(uuid.uuid4()),expectedRevision=0,tempo=tempo)
 call(a,'passages/save',{'input':p},at,expected=400)
report.update(savedSpeeds=[25,50,73,75,100,150],invalidSpeedsDenied=[24,73.5,151])
call(a,'serverpod_auth_core.status/signOutDevice',{},at)
call(a,'jwtRefresh/refreshAccessToken',{'refreshToken':None},expected=400)
report.update(guestPlaybackContent=True,anonymousWritesDenied=True,selfServiceEnabled=call(op,'emailIdp/selfServiceEnabled',{}),foreignOriginDenied=True,cookieRefresh=True,ownerIsolation=True,idempotentSave=True,revisionConflict=True,renameDelete=True,signOutRevokes=True)
(root/os.environ.get('ROLLINGTAB_BACKEND_REPORT','.private/independent-backend.json')).write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
