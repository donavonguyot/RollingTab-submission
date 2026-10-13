import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../audio/transport.dart';
import 'connection.dart';

String newRequestId() {
  final random = Random.secure();
  final b = List.generate(16, (_) => random.nextInt(256));
  b[6] = (b[6] & 15) | 64;
  b[8] = (b[8] & 63) | 128;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// Account-owned saved state, separate from public playback and musical rendering.
class PracticeLibrary extends ChangeNotifier {
  final BackendConnection backend;
  final TabTransport transport;
  SavedPassage? selected;
  PassageInput? _pending;
  String? _pendingFingerprint;
  late int _accountEpoch;
  int _selectionEpoch = 0;
  PracticeLibrary(this.backend, this.transport) {
    _accountEpoch = backend.accountEpoch;
    backend.addListener(_accountChanged);
  }
  void _accountChanged() {
    if (_accountEpoch != backend.accountEpoch) {
      _accountEpoch = backend.accountEpoch;
      clearSelection();
    }
  }

  void clearSelection() {
    _selectionEpoch++;
    selected = null;
    _pending = null;
    _pendingFingerprint = null;
    notifyListeners();
  }

  bool get canSave =>
      transport.fixture.provenance['connected'] == true &&
      'connected-${backend.artifact?.cid}' == transport.fixture.id;
  bool get dirty {
    final p = selected;
    return p == null ||
        p.start != transport.start ||
        p.end != transport.end ||
        p.tempo != transport.tempo ||
        p.loop != transport.looping;
  }

  Future<SavedPassage> save(String name, {bool asNew = false}) async {
    final a = backend.artifact;
    if (!canSave || a == null) {
      throw const BackendFailure('Load a server score before saving.');
    }
    final current = asNew ? null : selected;
    final fingerprint = jsonEncode([
      current?.passageId,
      a.cid,
      a.artifactVersion,
      name.trim(),
      transport.start,
      transport.end,
      transport.tempo,
      transport.looping,
    ]);
    if (_pending == null || fingerprint != _pendingFingerprint) {
      _pending = PassageInput(
        passageId: current?.passageId ?? newRequestId(),
        cid: a.cid,
        artifactVersion: a.artifactVersion,
        sourceSlot: a.sourceSlot,
        name: name.trim(),
        start: transport.start,
        end: transport.end,
        tempo: transport.tempo,
        loop: transport.looping,
        expectedRevision: current?.revision ?? 0,
        requestId: newRequestId(),
      );
      _pendingFingerprint = fingerprint;
    }
    final epoch = backend.accountEpoch;
    final selectionEpoch = _selectionEpoch;
    final result = await backend.save(_pending!);
    if (epoch != backend.accountEpoch) {
      throw const BackendFailure('Account changed during saving.');
    }
    if (selectionEpoch != _selectionEpoch) {
      throw const BackendFailure(
        'Passage saved, but the current selection changed. Reopen it from My passages.',
      );
    }
    selected = result;
    _pending = null;
    _pendingFingerprint = null;
    notifyListeners();
    return result;
  }

  Future<void> remove(SavedPassage p) async {
    await backend.delete(p);
    if (selected?.passageId == p.passageId) clearSelection();
  }

  void select(SavedPassage p) {
    _selectionEpoch++;
    selected = p;
    _pending = null;
    _pendingFingerprint = null;
    notifyListeners();
  }

  @override
  void dispose() {
    backend.removeListener(_accountChanged);
    super.dispose();
  }
}
