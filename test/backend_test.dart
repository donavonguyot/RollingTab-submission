import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:rollingtab/backend/connection.dart';

Map<String, dynamic> document({int program = 24}) => {
  'resolution': 480,
  'tempos': [
    {'time': 0, 'qpm': 120},
  ],
  'tracks': [
    {
      'name': 'Guitar',
      'program': program,
      'is_drum': false,
      'notes': [
        {'pitch': 64, 'time': 0, 'duration': 480},
      ],
    },
  ],
};
Map<String, dynamic> descriptor(Uint8List bytes, Uint8List raw) => {
  'contract_version': 'rolling-note-pdmx-artifact-v1',
  'logical_document': {
    'relpath': 'scores/test.json',
    'byte_size': raw.length,
    'sha256': sha256.convert(raw).toString(),
  },
  'artifact': {
    'relpath': 'scores/test.json.gz',
    'compression': 'gzip',
    'byte_size': bytes.length,
    'sha256': sha256.convert(bytes).toString(),
    'url': 'http://localhost:9895/score-bytes/${sha256.convert(bytes)}.json.gz',
  },
  'cache': {'key': 'scores/test.json.gz', 'byte_unit': 'compressed_bytes'},
};
Map<String, dynamic> auth() => {
  'authStrategy': 'jwt',
  'token': 'local-test-token',
  'refreshToken': 'local-test-refresh',
  'authUserId': 'c2359f12-a123-4123-8123-000000000001',
  'scopeNames': [],
};
void main() {
  test(
    'Verify compressed and logical identity before projecting guitar notes',
    () {
      final raw = Uint8List.fromList(utf8.encode(jsonEncode(document()))),
          bytes = Uint8List.fromList(
            GZipEncoder().encode(utf8.encode(jsonEncode(document()))),
          );
      final score = decodeArtifact(
        descriptor(bytes, raw),
        bytes,
        cid: 'test',
        slot: 0,
      );
      expect(score.notes.single.writtenMidi, 76);
      expect(score.notes.single.duration, closeTo(.5, 1e-9));
    },
  );
  test('Corrupt compressed bytes are rejected', () {
    final raw = Uint8List.fromList(utf8.encode(jsonEncode(document()))),
        bytes = Uint8List.fromList(GZipEncoder().encode(raw));
    final metadata = descriptor(bytes, raw);
    bytes[bytes.length - 1] ^= 1;
    expect(
      () => decodeArtifact(metadata, bytes, cid: 'test', slot: 0),
      throwsA(isA<BackendFailure>()),
    );
  });
  test('A different score identity is rejected', () {
    final raw = Uint8List.fromList([1]),
        bytes = Uint8List.fromList(GZipEncoder().encode(raw));
    expect(
      () =>
          decodeArtifact(descriptor(bytes, raw), bytes, cid: 'other', slot: 0),
      throwsA(isA<BackendFailure>()),
    );
  });
  test('Malformed decoded data is rejected', () {
    final raw = Uint8List.fromList(utf8.encode('{invalid')),
        bytes = Uint8List.fromList(GZipEncoder().encode(raw));
    expect(
      () => decodeArtifact(descriptor(bytes, raw), bytes, cid: 'test', slot: 0),
      throwsA(isA<BackendFailure>()),
    );
  });
  test('Missing guitar part and non-guitar parts are rejected', () {
    final raw = Uint8List.fromList(
          utf8.encode(jsonEncode(document(program: 0))),
        ),
        bytes = Uint8List.fromList(GZipEncoder().encode(raw));
    for (final slot in [0, 2]) {
      expect(
        () => decodeArtifact(
          descriptor(bytes, raw),
          bytes,
          cid: 'test',
          slot: slot,
        ),
        throwsA(isA<BackendFailure>()),
      );
    }
  });
  test('Authentication denial remains a failure', () async {
    final b = BackendConnection(
      client: MockClient((r) async => http.Response('{}', 401)),
    );
    await expectLater(
      b.login('test@example.invalid', 'unused'),
      throwsA(isA<BackendFailure>()),
    );
    expect(b.signedIn, false);
    b.dispose();
  });
  test(
    'Expired session clears private state without substituting a fixture',
    () async {
      final b = BackendConnection(
        client: MockClient(
          (r) async => r.url.path.endsWith('/login')
              ? http.Response(jsonEncode(auth()), 200)
              : http.Response('{}', 401),
        ),
      );
      await b.login('test@example.invalid', 'unused');
      await expectLater(b.passages(), throwsA(isA<BackendFailure>()));
      expect(b.signedIn, false);
      expect(b.receipt, isNull);
      b.dispose();
    },
  );
  test('Unavailable artifact does not become offline success', () async {
    final b = BackendConnection(
      client: MockClient(
        (r) async => r.url.path.endsWith('/login')
            ? http.Response(jsonEncode(auth()), 200)
            : http.Response('{}', 404),
      ),
    );
    await b.login('test@example.invalid', 'unused');
    await expectLater(b.loadScore(), throwsA(isA<BackendFailure>()));
    expect(b.receipt, isNull);
    b.dispose();
  });
  test('Failed refresh clears the old token', () async {
    final b = BackendConnection(
      client: MockClient(
        (r) async => r.url.path.endsWith('/login')
            ? http.Response(jsonEncode(auth()), 200)
            : http.Response('{}', 401),
      ),
    );
    await b.login('test@example.invalid', 'unused');
    await expectLater(b.refresh(), throwsA(isA<BackendFailure>()));
    expect(b.signedIn, false);
    b.dispose();
  });
}
