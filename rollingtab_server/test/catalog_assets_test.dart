import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:rollingtab_server/src/catalog.dart';

void main() {
  test('Allowlist verifies all bytes before publishing routes', () {
    final scores = readCatalogAssets();
    expect(scores.length, 5);
    expect(catalogBytes.length, 5);
    expect(
      scores.firstWhere((s) => s.cid == paganiniCid).artifactVersion,
      paganiniDigest,
    );
  });
  test('Malformed manifest, traversal, missing, corrupt and logical mismatch reject', () {
    final source = jsonDecode(
      File('assets/scores/repertoire.json').readAsStringSync(),
    ) as Map;
    for (final mode in [
      'path',
      'missing',
      'corrupt',
      'logical',
      'bounds',
      'duplicate',
      'version',
    ]) {
      final temp = Directory.systemTemp.createTempSync(
        'rollingtab-catalog-test-',
      );
      try {
        final m = jsonDecode(jsonEncode(source)) as Map;
        final row = (m['scores'] as List).first as Map;
        m['scores'] = [row];
        final bytes = File('assets/scores/${row['filename']}')
            .readAsBytesSync();
        File('${temp.path}/${row['filename']}').writeAsBytesSync(bytes);
        switch (mode) {
          case 'path':
            row['filename'] = '../outside.gz';
          case 'missing':
            File('${temp.path}/${row['filename']}').deleteSync();
          case 'corrupt':
            File('${temp.path}/${row['filename']}').writeAsBytesSync([1, 2]);
          case 'logical':
            row['logicalSha256'] = '0' * 64;
          case 'bounds':
            row['recommendedEnd'] = 10000;
          case 'duplicate':
            m['scores'] = [row, row];
          case 'version':
            m['version'] = 'unknown';
        }
        File('${temp.path}/repertoire.json').writeAsStringSync(jsonEncode(m));
        expect(
          () => readCatalogAssets(directory: temp.path),
          throwsA(anything),
          reason: mode,
        );
      } finally {
        temp.deleteSync(recursive: true);
      }
    }
  });
}
