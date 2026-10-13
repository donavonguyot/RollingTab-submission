import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:rollingtab_server/src/catalog.dart';
import 'package:rollingtab_server/src/passages.dart';
import 'package:rollingtab_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Independent practice', (builder, endpoints) {
    final ownerA = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
    final ownerB = UuidValue.fromString('22222222-2222-4222-8222-222222222222');
    late CatalogScore score;
    setUp(() async {
      final s = builder.build();
      await importCatalog(s);
      await importCatalog(s);
      score = (await endpoints.catalog.list(builder))
          .firstWhere((s) => s.cid == paganiniCid);
    });
    PassageInput input({
      double start = 79.385,
      double end = 109.385,
      int revision = 0,
      String request = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    }) => PassageInput(
      passageId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      cid: paganiniCid,
      artifactVersion: paganiniDigest,
      sourceSlot: 1,
      name: 'My passage',
      start: start,
      end: end,
      tempo: .75,
      loop: true,
      expectedRevision: revision,
      requestId: request,
    );
    test('Public catalog is exact and import is idempotent', () async {
      expect((await endpoints.catalog.list(builder)).length, 5);
      expect(
        (await endpoints.catalog.list(builder))
            .where((s) => s.sourceSlot == 0)
            .length,
        4,
      );
      expect(score.compressedBytes, 11953);
      expect(score.compressedSha256, paganiniDigest);
      expect(score.duration, 156);
      expect(
        (await endpoints.catalog.getArtifact(builder, paganiniCid)).sourceSlot,
        1,
      );
      await expectLater(
        endpoints.catalog.getArtifact(builder, 'missing'),
        throwsA(isA<BackendError>()),
      );
    });
    test(
      'Passages from every score retain artifact identity and arbitrary speed',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            ownerA.toString(),
            {},
          ),
        );
        final scores = await endpoints.catalog.list(builder);
        for (var i = 0; i < scores.length; i++) {
          final item = scores[i];
          final p = input()
            ..passageId = '00000000-0000-4000-8000-00000000000$i'
            ..requestId = '10000000-0000-4000-8000-00000000000$i'
            ..cid = item.cid
            ..artifactVersion = item.artifactVersion
            ..sourceSlot = item.sourceSlot
            ..start = item.recommendedStart!
            ..end = item.recommendedEnd!
            ..tempo = .73;
          final saved = await endpoints.passages.save(owner, p);
          expect(saved.cid, item.cid);
          expect(saved.tempo, .73);
        }
        expect((await endpoints.passages.list(owner)).length, 5);
      },
    );
    test('Non-finite times are rejected before persistence', () {
      for (final p in [
        input(start: double.nan),
        input(end: double.infinity),
        input()..tempo = double.nan,
      ]) {
        expect(() => validatePassage(p, score), throwsA(isA<BackendError>()));
      }
    });
    test('Whole-percent speed range saves and reloads without schema change', () async {
      final a = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerA.toString(),
          {},
        ),
      );
      var revision = 0;
      for (final speed in [.25, .5, .73, .75, 1.0, 1.5]) {
        final p = input(
          revision: revision,
          request:
              'cccccccc-cccc-4ccc-8ccc-${(revision + 1).toString().padLeft(12, '0')}',
        )..tempo = speed;
        final saved = await endpoints.passages.save(a, p);
        revision = saved.revision;
        expect((await endpoints.passages.list(a)).single.tempo, speed);
      }
    });
    test('Anonymous persistence denied', () async {
      await expectLater(
        endpoints.passages.list(builder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.passages.save(builder, input()),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
    test('Owners, idempotent retries, revisions and delete', () async {
      final a = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerA.toString(),
          {},
        ),
      );
      final b = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerB.toString(),
          {},
        ),
      );
      final first = await endpoints.passages.save(a, input());
      final retry = await endpoints.passages.save(a, input());
      expect(retry.id, first.id);
      expect(retry.revision, 1);
      expect(await endpoints.passages.list(b), isEmpty);
      await expectLater(
        endpoints.passages.save(b, input()),
        throwsA(isA<BackendError>()),
      );
      await expectLater(
        endpoints.passages.delete(b, first.passageId, 1),
        throwsA(isA<BackendError>()),
      );
      await expectLater(
        endpoints.passages.save(
          a,
          input(request: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'),
        ),
        throwsA(isA<BackendError>()),
      );
      final next = await endpoints.passages.save(
        a,
        input(revision: 1, request: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'),
      );
      expect(next.revision, 2);
      await expectLater(
        endpoints.passages.delete(a, first.passageId, 1),
        throwsA(isA<BackendError>()),
      );
      await endpoints.passages.delete(a, first.passageId, 2);
      expect(await endpoints.passages.list(a), isEmpty);
    });
    test('Reject invalid bounds, tempo, version and slot', () async {
      final a = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerA.toString(),
          {},
        ),
      );
      for (final p in [
        input(start: -1),
        input(end: 156.1),
        input(start: 0, end: 61),
        input()..tempo = .735,
        input()..tempo = .24,
        input()..tempo = 1.51,
        input()..artifactVersion = 'other',
        input()..sourceSlot = 0,
        input()..name = '',
      ]) {
        await expectLater(
          endpoints.passages.save(a, p),
          throwsA(isA<BackendError>()),
        );
      }
    });
  });
}
