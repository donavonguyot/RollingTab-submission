import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rollingtab/backend/connection.dart';
import 'package:rollingtab/backend/practice_library.dart';
import 'package:rollingtab/audio/transport.dart';

import 'transport_test.dart' show FakeAudio;
import 'backend_test.dart' show auth;

const cid = 'QmcmrMSehjpEW3yzzstiCECCTxLNBapeRrnQKc7rrWCB26';
CatalogScore metadata() => CatalogScore(
  cid: cid,
  title: 'Paganini',
  composer: 'Paganini',
  artifactVersion:
      '3f5e9fbe15c4b1c43c20f7d6108bcf85ccb2b4ba2c0809cf388aed18f71e70f6',
  sourceSlot: 1,
  duration: 156,
  license: 'cc-zero',
  licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
  compressedSha256:
      '3f5e9fbe15c4b1c43c20f7d6108bcf85ccb2b4ba2c0809cf388aed18f71e70f6',
  compressedBytes: 11953,
  logicalSha256:
      'f40dc4bd7e195445aab7577b1ee31387ebe07a3a2532b812fb4c13fb16be686b',
  logicalBytes: 260909,
  downloadPath: '/score-bytes/3f5e9fbe15c4b1c43c20f7d6108bcf85ccb2b4ba2c0809cf388aed18f71e70f6.json.gz',
);
void main() {
  test(
    'Guest loads exact independent artifact and receipt without authentication',
    () async {
      final b = BackendConnection(
        client: MockClient((r) async {
          expect(r.url.origin, 'http://localhost:9893');
          expect(r.url.path, '/catalog/getArtifact');
          return http.Response(jsonEncode(metadata().toJson()), 200);
        }),
        bytesClient: MockClient((r) async {
          expect(r.url.origin, 'http://localhost:9895');
          expect(r.headers.containsKey('authorization'), false);
          return http.Response.bytes(
            File('rollingtab_server/assets/scores/paganini-guitar.pdmx.json.gz')
                .readAsBytesSync(),
            200,
          );
        }),
      );
      final score = await b.loadScore();
      expect(b.signedIn, false);
      expect(score.notes.length, 482);
      expect(score.duration, 156);
      expect(b.receipt!['compressedBytes'], 11953);
      expect(score.provenance['connected'], true);
      b.dispose();
    },
  );
  test('Failed save retry reuses identifiers and account change clears private selection', () async {
    final requests = <Map<String, dynamic>>[];
    bool fail = true;
    final b = BackendConnection(
      client: MockClient((r) async {
        if (r.url.path.endsWith('/login')) {
          return http.Response(jsonEncode(auth()), 200);
        }
        if (r.url.path.endsWith('/signOutDevice')) {
          return http.Response('null', 200);
        }
        if (r.url.path == '/catalog/getArtifact') {
          return http.Response(jsonEncode(metadata().toJson()), 200);
        }
        final input = Map<String, dynamic>.from(jsonDecode(r.body)['input']);
        requests.add(input);
        if (fail) throw const SocketException('temporary network failure');
        return http.Response(
          jsonEncode({
            ...input,
            '__className__': 'SavedPassage',
            'owner': auth()['authUserId'],
            'revision': 1,
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
          }),
          200,
        );
      }),
      bytesClient: MockClient(
        (_) async => http.Response.bytes(
          File('rollingtab_server/assets/scores/paganini-guitar.pdmx.json.gz')
              .readAsBytesSync(),
          200,
        ),
      ),
    );
    final score = await b.loadScore();
    final t = TabTransport(score, FakeAudio());
    await t.setPassage(79.385, 109.385);
    final l = PracticeLibrary(b, t);
    await b.login('test@example.invalid', 'unused');
    expect(l.canSave, true);
    await expectLater(l.save('Practice'), throwsA(anything));
    fail = false;
    final saved = await l.save('Practice');
    expect(requests[0]['requestId'], requests[1]['requestId']);
    expect(requests[0]['passageId'], saved.passageId);
    expect(l.dirty, false);
    await t.setPassage(80, 100);
    expect(l.dirty, true);
    final time = t.time;
    await b.signOut();
    expect(l.selected, isNull);
    expect(t.time, time);
    expect(t.fixture.id, score.id);
    l.dispose();
    t.dispose();
    b.dispose();
  });
}
