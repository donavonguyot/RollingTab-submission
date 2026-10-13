import 'dart:math' as math;

import 'music.dart';
import '../vendor/pdmx_document.dart';

const openStrings = [0, 64, 59, 55, 50, 45, 40];

/// Assign simultaneous notes together, reserving strings occupied by sustains.
/// Authored positions take priority. Unresolved notes remain audible but unplaced.
TabScore projectGuitar(TabScore input) {
  final ordered = [...input.notes]
    ..sort((a, b) {
      final d = a.start.compareTo(b.start);
      return d == 0 ? a.id.compareTo(b.id) : d;
    });
  final result = <TabNote>[];
  final diagnostics = <String>[];
  for (var at = 0; at < ordered.length;) {
    var end = at + 1;
    while (end < ordered.length &&
        (ordered[end].start - ordered[at].start).abs() < .00001) {
      end++;
    }
    final group = ordered.sublist(at, end);
    final used = result
        .where((n) => n.stringNumber > 0 && n.end > group.first.start + .00001)
        .map((n) => n.stringNumber)
        .toSet();
    final chosen = <String, (int, int)>{};
    for (final n in group.where(
      (n) => n.source == 'authored' && n.stringNumber > 0,
    )) {
      if (n.stringNumber <= 6 &&
          n.fret >= 0 &&
          n.fret <= 24 &&
          openStrings[n.stringNumber] + n.fret == n.midi &&
          !used.contains(n.stringNumber)) {
        chosen[n.id] = (n.stringNumber, n.fret);
        used.add(n.stringNumber);
      } else {
        diagnostics.add(
          '${n.id}: authored position conflicts or is invalid; position withheld.',
        );
      }
    }
    final pending = group
        .where((n) => !(n.source == 'authored' && n.stringNumber > 0))
        .toList();
    final previous = result.isEmpty ? 0 : result.last.fret;
    Map<String, (int, int)> best = {};
    double bestCost = double.infinity;
    void search(
      int i,
      Set<int> occupied,
      Map<String, (int, int)> positions,
      double cost,
    ) {
      if (i == pending.length) {
        final total = cost + (pending.length - positions.length) * 1000;
        if (total < bestCost) {
          bestCost = total;
          best = Map.of(positions);
        }
        return;
      }
      final n = pending[i];
      for (var s = 1; s <= 6; s++) {
        final fret = n.midi - openStrings[s];
        if (occupied.contains(s) || fret < 0 || fret > 24) continue;
        occupied.add(s);
        positions[n.id] = (s, fret);
        search(
          i + 1,
          occupied,
          positions,
          cost + (fret - previous).abs() + fret * .2,
        );
        occupied.remove(s);
        positions.remove(n.id);
      }
      search(i + 1, occupied, positions, cost);
    }

    // Guitar chords contain at most six voices; bound pathological input search.
    if (pending.length <= 8) {
      search(0, Set.of(used), {}, 0);
    } else {
      diagnostics.add(
        'Dense onset at ${group.first.start}: more than eight voices; inferred positions withheld.',
      );
    }
    chosen.addAll(best);
    for (final n in group) {
      final p = chosen[n.id];
      if (p == null) {
        diagnostics.add(
          '${n.id}: no unoccupied playable string; position withheld.',
        );
      }
      result.add(
        TabNote.fromJson({
          ...n.toJson(),
          'string': p?.$1 ?? 0,
          'fret': p?.$2 ?? 0,
          'source': n.source == 'authored' && n.stringNumber > 0
              ? 'authored'
              : 'inferred',
        }),
      );
    }
    at = end;
  }
  return TabScore.fromJson({
    ...input.toJson(),
    'notes': result.map((n) => n.toJson()).toList(),
    'provenance': {
      ...input.provenance,
      'diagnostics': diagnostics,
      'fretMax': math.max(
        5,
        result.fold<int>(0, (a, n) => math.max(a, n.fret)),
      ),
    },
  });
}

TabScore scoreFromDocument(
  PdmxDocument document, {
  required String cid,
  required int slot,
  required Map<String, dynamic> provenance,
}) {
  if (slot < 0 || slot >= document.tracks.length) {
    throw const FormatException('Configured guitar track is missing.');
  }
  final track = document.tracks[slot];
  if (track.isDrum || track.program < 24 || track.program > 31) {
    throw const FormatException('Configured part is not a guitar track.');
  }
  final tempos = normalizeTempos(document.tempos);
  final notes = <TabNote>[];
  for (var i = 0; i < track.notes.length; i++) {
    final n = track.notes[i];
    if (n.isGrace) continue;
    final start = wallMsAtDivision(n.time, document.resolution, tempos) / 1000;
    final duration =
        durationMsInDivisions(n.time, n.duration, document.resolution, tempos) /
        1000;
    if (duration <= 0) continue;
    notes.add(
      TabNote(
        id: '$cid:$slot:$i',
        midi: n.pitch,
        start: start,
        duration: duration,
        stringNumber: n.guitarString ?? 0,
        fret: n.guitarFret ?? 0,
        source: n.guitarString != null && n.guitarFret != null
            ? 'authored'
            : 'inferred',
        writtenMidi: n.pitch + 12,
      ),
    );
  }
  if (notes.isEmpty) {
    throw const FormatException('Guitar part has no playable notes.');
  }
  return projectGuitar(
    TabScore(
      id: 'connected-$cid',
      title: document.metadata.title ?? 'Guitar passage',
      notes: notes,
      duration: notes.fold<double>(0, (v, n) => math.max(v, n.end)),
      program: track.program,
      guitar: true,
      attribution: notes.every((n) => n.source == 'authored')
          ? 'Source TAB · string/fret positions from the score'
          : notes.any((n) => n.source == 'authored')
          ? 'Mixed guidance · source TAB and inferred positions'
          : 'Inferred guidance · positions are suggestions, not finger assignments',
      provenance: {
        ...provenance,
        'sourceSlot': slot,
        'connected': true,
        'tempoMap': [
          for (final t in tempos)
            {
              'seconds':
                  wallMsAtDivision(t.time, document.resolution, tempos) / 1000,
              'bpm': t.qpm,
            },
        ],
      },
    ),
  );
}
