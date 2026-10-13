import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';

Never fail(String code, String message) =>
    throw BackendError(code: code, message: message);

void validatePassage(PassageInput p, CatalogScore score) {
  final uuid = RegExp(
    r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
  );
  if (!uuid.hasMatch(p.passageId) ||
      !uuid.hasMatch(p.requestId) ||
      p.expectedRevision < 0 ||
      p.name.trim().isEmpty ||
      p.name.trim().length > 80 ||
      !p.start.isFinite ||
      !p.end.isFinite ||
      !p.tempo.isFinite ||
      p.start < 0 ||
      p.end <= p.start ||
      p.end > score.duration + 0.000001 ||
      p.end - p.start > 60.000001 ||
      (p.tempo < .25 ||
          p.tempo > 1.5 ||
          (p.tempo * 100 - (p.tempo * 100).round()).abs() > 1e-8)) {
    fail(
      'invalid',
      'Use a name and a passage of up to 60 score seconds at a whole percentage from 25% to 150%.',
    );
  }
  if (p.artifactVersion != score.artifactVersion ||
      p.sourceSlot != score.sourceSlot) {
    fail(
      'artifact_changed',
      'This saved passage references a different score version or part.',
    );
  }
}

class PassagesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<SavedPassage>> list(Session session) => SavedPassage.db.find(
    session,
    where: (t) => t.owner.equals(session.authenticated!.authUserId),
    orderBy: (t) => t.updatedAt,
  );

  Future<SavedPassage> save(Session session, PassageInput input) async {
    final owner = session.authenticated!.authUserId;
    return session.db.transaction((tx) async {
      // Lock the passage identity, including first creation; retries cannot duplicate rows.
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@key, 0))',
        parameters: QueryParameters.named({'key': input.passageId}),
        transaction: tx,
      );
      final score = await CatalogScore.db.findFirstRow(
        session,
        where: (t) => t.cid.equals(input.cid),
        transaction: tx,
      );
      if (score == null) fail('unavailable', 'This score is unavailable.');
      validatePassage(input, score);
      input.tempo = (input.tempo * 100).round() / 100;
      final old = await SavedPassage.db.findFirstRow(
        session,
        where: (t) => t.passageId.equals(input.passageId),
        transaction: tx,
      );
      if (old != null && old.owner != owner) {
        fail('not_found', 'Passage not found.');
      }
      if (old != null && old.requestId == input.requestId) {
        if (old.cid == input.cid &&
            old.artifactVersion == input.artifactVersion &&
            old.sourceSlot == input.sourceSlot &&
            old.name == input.name.trim() &&
            old.start == input.start &&
            old.end == input.end &&
            old.tempo == input.tempo &&
            old.loop == input.loop) {
          return old;
        }
        fail('conflict', 'This request identifier was already used.');
      }
      if ((old?.revision ?? 0) != input.expectedRevision) {
        fail(
          'conflict',
          'This passage changed elsewhere. Reopen it before updating.',
        );
      }
      final now = DateTime.now().toUtc();
      final row = SavedPassage(
        id: old?.id,
        passageId: input.passageId,
        owner: owner,
        cid: input.cid,
        artifactVersion: input.artifactVersion,
        sourceSlot: input.sourceSlot,
        name: input.name.trim(),
        start: input.start,
        end: input.end,
        tempo: input.tempo,
        loop: input.loop,
        revision: (old?.revision ?? 0) + 1,
        requestId: input.requestId,
        createdAt: old?.createdAt ?? now,
        updatedAt: now,
      );
      return old == null
          ? SavedPassage.db.insertRow(session, row, transaction: tx)
          : SavedPassage.db.updateRow(session, row, transaction: tx);
    });
  }

  Future<void> delete(
    Session session,
    String passageId,
    int expectedRevision,
  ) async {
    await session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@key, 0))',
        parameters: QueryParameters.named({'key': passageId}),
        transaction: tx,
      );
      final old = await SavedPassage.db.findFirstRow(
        session,
        where: (t) => t.passageId.equals(passageId),
        transaction: tx,
      );
      if (old == null) return;
      if (old.owner != session.authenticated!.authUserId) {
        fail('not_found', 'Passage not found.');
      }
      if (old.revision != expectedRevision) {
        fail(
          'conflict',
          'This passage changed elsewhere. Refresh before deleting.',
        );
      }
      await SavedPassage.db.deleteRow(session, old, transaction: tx);
    });
  }
}
