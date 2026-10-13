import 'music.dart';

class ChordCue {
  final String name;
  final double at;
  const ChordCue(this.name, this.at);
}

/// Musical state is reconstructed from absolute score time, never animation deltas.
class VoicingStudy {
  final TabScore fixture;
  late final List<ChordCue> cues;
  VoicingStudy(this.fixture) {
    final times = <double>{
      0,
      for (final n in fixture.notes) ...[n.start, n.end],
    };
    final authored = fixture.provenance['voicingStudy'] as Map?;
    for (final c in authored?['cues'] ?? []) {
      times.add((c['at'] as num).toDouble());
    }
    final ordered = times.toList()..sort();
    cues = [for (final t in ordered) ChordCue(_nameAt(t), t)];
  }
  static bool supports(TabScore f) => f.guitar;
  String _nameAt(double time) {
    String name = 'Positions';
    for (final c in fixture.provenance['voicingStudy']?['cues'] ?? []) {
      if ((c['at'] as num) <= time) name = c['name'];
    }
    return name;
  }

  double get beatSeconds =>
      (fixture.provenance['voicingStudy']?['beatSeconds'] as num?)
          ?.toDouble() ??
      .5;
  double beatsAt(double t) {
    final tempos = fixture.provenance['tempoMap'] as List?;
    if (tempos == null || tempos.isEmpty) return t / beatSeconds;
    double beats = 0, at = 0, bpm = 120;
    for (final change in tempos) {
      final start = (change['seconds'] as num).toDouble();
      if (start > t) break;
      beats += (start - at) * bpm / 60;
      at = start;
      bpm = (change['bpm'] as num).toDouble();
    }
    return beats + (t - at) * bpm / 60;
  }

  List<TabNote> notesAt(double time) =>
      fixture.notes.where((n) => n.stringNumber > 0 && n.active(time)).toList();
  List<TabNote> shapeAt(double time) {
    List<dynamic>? ids;
    for (final c in fixture.provenance['voicingStudy']?['cues'] ?? []) {
      if ((c['at'] as num) <= time) ids = c['shapeIds'] as List?;
    }
    return ids == null
        ? []
        : fixture.notes.where((n) => ids!.contains(n.id)).toList();
  }

  VoicingFrame at(double time, double leadBeats) {
    ChordCue? current, next;
    for (final cue in cues) {
      if (cue.at <= time + 1e-8) {
        current = cue;
      } else {
        next = cue;
        break;
      }
    }
    final sounding = notesAt(time);
    final target = next == null ? <TabNote>[] : notesAt(next.at);
    final before = current == null ? <TabNote>[] : notesAt(current.at - .00001);
    final incoming = current == null ? <TabNote>[] : notesAt(current.at);
    final until = next == null ? 0.0 : beatsAt(next.at) - beatsAt(time);
    return VoicingFrame(
      current,
      next,
      sounding,
      target,
      before.where((n) => !incoming.any((x) => x.id == n.id)).toList(),
      until,
      next == null ? 0 : (1 - until / leadBeats).clamp(0.0, 1.0),
      current == null
          ? 1
          : ((beatsAt(time) - beatsAt(current.at)) / .4).clamp(0.0, 1.0),
      shapeAt(time),
    );
  }
}

class VoicingFrame {
  final ChordCue? current, next;
  final List<TabNote> sounding, target, released, prepared;
  final double beatsUntil, preview, arrival;
  VoicingFrame(
    this.current,
    this.next,
    this.sounding,
    this.target,
    this.released,
    this.beatsUntil,
    this.preview,
    this.arrival,
    this.prepared,
  );
  bool continues(TabNote n) => target.any((x) => x.id == n.id);
  bool holdsPosition(TabNote n) =>
      target.any((x) => x.stringNumber == n.stringNumber && x.fret == n.fret);
  Map<String, dynamic> toJson() => {
    'current': current?.name,
    'next': next?.name,
    'beatsUntil': beatsUntil,
    'sounding': sounding.map((n) => n.id).toList(),
    'continuing': sounding.where(continues).map((n) => n.id).toList(),
    'target': target.map((n) => n.id).toList(),
    'released': released.map((n) => n.id).toList(),
    'prepared': prepared.map((n) => n.id).toList(),
    'preview': preview,
    'arrival': arrival,
  };
}
