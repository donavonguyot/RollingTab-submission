import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rollingtab/backend/connection.dart';
import 'package:rollingtab/model/music.dart';

void main() {
  final rows =
      (jsonDecode(
                File('rollingtab_server/assets/scores/repertoire.json')
                    .readAsStringSync(),
              )['scores']
              as List)
          .cast<Map>();
  CatalogScore descriptor(Map r) => CatalogScore.fromJson({
    ...r,
    '__className__': 'CatalogScore',
    'duration': 1000.0,
    'artifactVersion': r['compressedSha256'],
    'downloadPath': '/score-bytes/${r['compressedSha256']}.json.gz',
  });
  BackendConnection connection({Completer<void>? wait}) => BackendConnection(
    client: MockClient((req) async {
      final cid = jsonDecode(req.body)['cid'];
      if (wait != null && cid == rows.first['cid']) await wait.future;
      return http.Response(
        jsonEncode(
          descriptor(rows.firstWhere((r) => r['cid'] == cid)).toJson(),
        ),
        200,
      );
    }),
    bytesClient: MockClient((req) async {
      final r = rows.firstWhere(
        (r) => req.url.path.contains(r['compressedSha256']),
      );
      return http.Response.bytes(
        File('rollingtab_server/assets/scores/${r['filename']}')
            .readAsBytesSync(),
        200,
      );
    }),
  );
  test('All five submission source parts decode; source TAB and inferred diagnostics are preserved', () async {
    final b = connection();
    final report = <Map<String, dynamic>>[];
    for (final r in rows) {
      final s = await b.loadScore(cid: r['cid']);
      expect(s.notes, isNotEmpty);
      expect(b.artifact!.sourceSlot, r['sourceSlot']);
      final a = (r['recommendedStart'] as num).toDouble(),
          z = (r['recommendedEnd'] as num).toDouble();
      expect(z, lessThanOrEqualTo(s.duration + .001));
      final ns = s.notes.where((n) => n.start < z && n.end > a).toList();
      int span = 0, jump = 0;
      TabNote? previous;
      for (final n in ns.where((n) => n.stringNumber > 0)) {
        if (previous != null) {
          final d = (n.fret - previous.fret).abs();
          if (d > jump) jump = d;
        }
        previous = n;
        final frets =
            ns
                .where(
                  (x) =>
                      x.stringNumber > 0 &&
                      x.fret > 0 &&
                      x.start <= n.start &&
                      x.end > n.start,
                )
                .map((x) => x.fret)
                .toList()
              ..sort();
        if (frets.isNotEmpty && frets.last - frets.first > span) {
          span = frets.last - frets.first;
        }
      }
      report.add({
        'key': r['key'],
        'cid': r['cid'],
        'duration': s.duration,
        'notes': s.notes.length,
        'passage': [a, z],
        'passageNotes': ns.length,
        'placed': ns.where((n) => n.stringNumber > 0).length,
        'sourceTab': ns.where((n) => n.source == 'authored').length,
        'maxFrettedSpan': span,
        'maxConsecutiveEventFretJump': jump,
        'diagnostics': s.provenance['diagnostics'],
      });
      if (r['key'] == 'carulli-sautillante') {
        expect(s.notes.length, 148);
        expect(
          s.notes.every((n) => n.source == 'authored' && n.stringNumber > 0),
          true,
        );
      }
    }
    File('${Directory.systemTemp.path}/rollingtab-submission-projection.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
    b.dispose();
  });
  test('A slow previous score cannot overwrite the latest score', () async {
    final wait = Completer<void>(), b = connection(wait: Completer<void>());
    b.dispose();
    final c = connection(wait: wait);
    final old = c.loadScore(cid: rows.first['cid']);
    final check = expectLater(old, throwsA(isA<BackendFailure>()));
    await c.loadScore(cid: rows[1]['cid']);
    wait.complete();
    await check;
    expect(c.artifact!.cid, rows[1]['cid']);
    c.dispose();
  });
  test('Cancellation invalidates pending score results', () async {
    final wait = Completer<void>(), c = connection(wait: Completer<void>());
    c.dispose();
    final b = connection(wait: wait), old = b.loadScore(cid: rows.first['cid']);
    final check = expectLater(old, throwsA(isA<BackendFailure>()));
    b.cancelScoreLoad();
    wait.complete();
    await check;
    expect(b.artifact, isNull);
    b.dispose();
  });
}
