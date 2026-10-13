import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

const paganiniCid = 'QmcmrMSehjpEW3yzzstiCECCTxLNBapeRrnQKc7rrWCB26';
const paganiniDigest =
    '3f5e9fbe15c4b1c43c20f7d6108bcf85ccb2b4ba2c0809cf388aed18f71e70f6';
final scoreFile = File('assets/scores/paganini-guitar.pdmx.json.gz');

/// Immutable allowlist; validate every asset before registering any byte route.
Map<String, List<int>> catalogBytes = {};
List<CatalogScore> readCatalogAssets({String directory = 'assets/scores'}) {
  final manifest =
      jsonDecode(File('$directory/repertoire.json').readAsStringSync()) as Map;
  if (manifest['version'] != 'rollingtab-repertoire-v1') {
    throw StateError('Unsupported repertoire manifest');
  }
  final scores = <CatalogScore>[];
  final bytesByDigest = <String, List<int>>{};
  final ids = <String>{};
  for (final row in (manifest['scores'] as List).cast<Map>()) {
    final filename = row['filename'] as String;
    if (!RegExp(r'^[a-z0-9-]+[.]pdmx[.]json[.]gz$').hasMatch(filename)) {
      throw StateError('Invalid asset path');
    }
    final bytes = File('$directory/$filename').readAsBytesSync();
    final digest = sha256.convert(bytes).toString();
    if (bytes.length != row['compressedBytes'] ||
        digest != row['compressedSha256']) {
      throw StateError('Compressed asset failed verification: $filename');
    }
    final raw = GZipDecoder().decodeBytes(bytes);
    if (raw.length != row['logicalBytes'] ||
        sha256.convert(raw).toString() != row['logicalSha256']) {
      throw StateError('Logical asset failed verification: $filename');
    }
    final d = jsonDecode(utf8.decode(raw)) as Map;
    final slot = row['sourceSlot'] as int;
    final track = (d['tracks'] as List)[slot] as Map;
    if (track['is_drum'] == true ||
        (track['program'] as num) < 24 ||
        (track['program'] as num) > 31 ||
        d['absolute_time'] == true) {
      throw StateError('Invalid guitar artifact');
    }
    final notes = (track['notes'] as List).cast<Map>();
    final end = notes
        .map((n) => (n['time'] as num) + (n['duration'] as num))
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final tempos = (d['tempos'] as List).cast<Map>()
      ..sort((a, b) => (a['time'] as num).compareTo(b['time'] as num));
    double duration = 0, cursor = 0, qpm = 120;
    for (final t in tempos) {
      final at = (t['time'] as num).toDouble().clamp(0.0, end).toDouble();
      duration += (at - cursor) / (d['resolution'] as num) * 60 / qpm;
      cursor = at;
      qpm = (t['qpm'] as num).toDouble();
      if (!qpm.isFinite || qpm <= 0) throw StateError('Invalid tempo');
      if (cursor == end) break;
    }
    duration += (end - cursor) / (d['resolution'] as num) * 60 / qpm;
    final start = (row['recommendedStart'] as num).toDouble(),
        stop = (row['recommendedEnd'] as num).toDouble();
    if (!duration.isFinite ||
        !start.isFinite ||
        !stop.isFinite ||
        start < 0 ||
        stop <= start ||
        stop > duration ||
        stop - start > 60) {
      throw StateError('Invalid recommended passage');
    }
    if (!ids.add(row['cid']) || bytesByDigest.containsKey(digest)) {
      throw StateError('Duplicate repertoire identity');
    }
    if (row['cid'] == paganiniCid && digest != paganiniDigest) {
      throw StateError('Paganini identity changed');
    }
    scores.add(
      CatalogScore(
        cid: row['cid'],
        title: row['title'],
        composer: row['composer'],
        artifactVersion: digest,
        sourceSlot: slot,
        duration: duration,
        license: row['license'],
        licenseUrl: row['licenseUrl'],
        compressedSha256: digest,
        compressedBytes: bytes.length,
        logicalSha256: row['logicalSha256'],
        logicalBytes: raw.length,
        downloadPath: '/score-bytes/$digest.json.gz',
        recommendedStart: start,
        recommendedEnd: stop,
        practiceFocus: row['practiceFocus'],
        guidanceDescription: row['guidanceDescription'],
      ),
    );
    bytesByDigest[digest] = List.unmodifiable(bytes);
  }
  catalogBytes = Map.unmodifiable(bytesByDigest);
  return scores;
}

Future<CatalogScore> readCatalogAsset() async =>
    readCatalogAssets().firstWhere((s) => s.cid == paganiniCid);
Future<void> importCatalog(Session session) async {
  final artifacts = readCatalogAssets();
  await session.db.transaction((tx) async {
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(9893001)',
      transaction: tx,
    );
    for (final artifact in artifacts) {
      final old = await CatalogScore.db.findFirstRow(
        session,
        where: (t) => t.cid.equals(artifact.cid),
        transaction: tx,
      );
      if (old == null) {
        await CatalogScore.db.insertRow(session, artifact, transaction: tx);
      } else {
        if (old.artifactVersion != artifact.artifactVersion) {
          throw StateError(
            'Existing catalog version differs; explicit version migration required',
          );
        }
        artifact.id = old.id;
        await CatalogScore.db.updateRow(session, artifact, transaction: tx);
      }
    }
  });
}

class CatalogEndpoint extends Endpoint {
  Future<List<CatalogScore>> list(Session session) =>
      CatalogScore.db.find(session, orderBy: (t) => t.title);
  Future<CatalogScore> getArtifact(Session session, String cid) async {
    final row = await CatalogScore.db.findFirstRow(
      session,
      where: (t) => t.cid.equals(cid),
    );
    if (row == null) {
      throw BackendError(
        code: 'unavailable',
        message: 'This score is unavailable.',
      );
    }
    return row;
  }
}
