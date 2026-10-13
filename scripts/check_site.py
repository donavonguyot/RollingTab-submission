#!/usr/bin/env python3
"""HTTP contracts for the static homepage and prefixed Flutter app."""
import hashlib,json,urllib.request,urllib.error,os
from html.parser import HTMLParser
from pathlib import Path
Path(__file__).resolve().parents[1].joinpath('.private').mkdir(exist_ok=True)
BASE=os.environ.get('ROLLINGTAB_VERIFY_BASE','http://localhost:9895').rstrip('/')
class Page(HTMLParser):
 def __init__(self):super().__init__();self.tags=[]
 def handle_starttag(self,tag,attrs):self.tags.append((tag,dict(attrs)))
def get(path):
 with urllib.request.urlopen(BASE+path,timeout=20) as r:return r.read(),dict(r.headers),r.status
html,headers,_=get('/');page=Page();page.feed(html.decode())
assert 'See the timing.' in html.decode() and b'Prepare the next shape.' in html
assert not any(tag=='script' for tag,_ in page.tags)
assert not any('flutter' in str(a).lower() or 'soundfont/' in str(a).lower() or '/api/' in str(a) for _,a in page.tags)
v=next(a for t,a in page.tags if t=='video');assert 'controls' in v and 'playsinline' in v and v['preload']=='none' and 'autoplay' not in v and 'loop' not in v
assert any(t=='a' and a.get('href')=='/play/' for t,a in page.tags)
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,*args,**kwargs):return None
try:urllib.request.build_opener(NoRedirect).open(BASE+'/play')
except urllib.error.HTTPError as e:assert e.code in (301,308) and e.headers['Location'].endswith('/play/')
else:raise AssertionError('Missing redirect')
app,h,_=get('/play/');assert b'<base href="/play/">' in app
assert h.get('cross-origin-opener-policy',h.get('Cross-Origin-Opener-Policy'))=='same-origin'
assert h.get('cross-origin-embedder-policy',h.get('Cross-Origin-Embedder-Policy'))=='require-corp'
paths={'/play/main.dart.wasm':'application/wasm','/site-assets/site.css':'text/css','/site-assets/chord-handoff.mp4':'video/mp4','/site-assets/chord-handoff.jpg':'image/jpeg','/play/assets/assets/soundfont/GeneralUser_GS.sf2':'octet-stream'}
results={}
for path,mime in paths.items():
 b,h,status=get(path);kind=h.get('content-type',h.get('Content-Type',''));assert mime in kind,(path,kind)
 if path.startswith('/play/'):
  assert h.get('cross-origin-opener-policy',h.get('Cross-Origin-Opener-Policy'))=='same-origin'
  assert h.get('cross-origin-embedder-policy',h.get('Cross-Origin-Embedder-Policy'))=='require-corp'
 results[path]={'bytes':len(b),'contentType':kind,'status':status}
request=urllib.request.Request(BASE+'/site-assets/chord-handoff.mp4',headers={'Range':'bytes=0-99'})
with urllib.request.urlopen(request) as r:assert r.status==206 and len(r.read())==100
p=Path(os.environ.get('ROLLINGTAB_ROUTES_REPORT','.private/continuous-routes.json'));p.write_text(json.dumps({'base':BASE,'homepageBytes':len(html),'staticNoScripts':True,'clickToPlay':True,'playRedirect':True,'isolatedFlutter':True,'mediaRangeRequests':True,'assets':results},indent=2)+'\n')
print(p.read_text())
