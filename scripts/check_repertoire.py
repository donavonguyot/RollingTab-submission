#!/usr/bin/env python3
"""Local-only score delivery and package verification; never publish."""
import gzip,hashlib,json,urllib.request,urllib.error,os
from pathlib import Path
Path(__file__).resolve().parents[1].joinpath('.private').mkdir(exist_ok=True)
ROOT=Path(__file__).resolve().parents[1];BASE=os.environ.get('ROLLINGTAB_VERIFY_BASE','http://localhost:9895').rstrip('/')
m=json.loads((ROOT/'rollingtab_server/assets/scores/repertoire.json').read_text())
req=urllib.request.Request(BASE+'/api/catalog/list',data=b'{}',headers={'Content-Type':'application/json','Origin':BASE})
response=urllib.request.urlopen(req);assert response.headers.get_content_type()=='application/json';assert response.headers.get_content_charset()=='utf-8'
rows=json.load(response);assert len(rows)==len(m["scores"])
report={'base':BASE,'scores':[]}
for r in m['scores']:
 d=next(x for x in rows if x['cid']==r['cid']);response=urllib.request.urlopen(BASE+d['downloadPath']);b=response.read();raw=gzip.decompress(b)
 assert response.headers.get_content_type()=='application/gzip';assert response.headers.get('Content-Encoding') is None
 assert hashlib.sha256(b).hexdigest()==r['compressedSha256']==d['compressedSha256'];assert len(b)==r['compressedBytes']
 assert hashlib.sha256(raw).hexdigest()==r['logicalSha256'];assert len(raw)==r['logicalBytes']
 assert d['title']==r['title'] and d['composer']==r['composer']
 assert d['sourceSlot']==r['sourceSlot'] and d['recommendedEnd']==r['recommendedEnd']
 report['scores'].append({'key':r['key'],'compressedBytes':len(b),'sha256':d['compressedSha256'],'sourceSlot':d['sourceSlot'],'verified':True})
for path in ['/score-bytes/'+'0'*64+'.json.gz','/score-bytes/repertoire.json','/score-bytes/sources/carulli-sautillante.mxl',rows[0]['downloadPath']+'?other=1']:
 try:urllib.request.urlopen(BASE+path);raise AssertionError('Unexpected download: '+path)
 except urllib.error.HTTPError as e:assert e.code==404
report['unknownDownloadsDenied']=True
(ROOT/os.environ.get('ROLLINGTAB_REPERTOIRE_REPORT','.private/repertoire-delivery.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
