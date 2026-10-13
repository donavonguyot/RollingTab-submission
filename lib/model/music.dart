import 'dart:math' as math;

enum FeedbackMode { off, correct, imperfect }

class TabNote {
  final String id;
  final int midi, stringNumber, fret, staffStep;
  final double start, duration;
  final String technique, source, accidental, beam, tie;
  final int writtenMidi;
  const TabNote({
    required this.id,
    required this.midi,
    required this.start,
    required this.duration,
    this.stringNumber = 0,
    this.fret = 0,
    this.technique = '',
    this.source = 'authored',
    this.staffStep = 0,
    this.accidental = '',
    this.beam = '',
    this.tie = '',
    int? writtenMidi,
  }) : writtenMidi = writtenMidi ?? midi;
  double get end => start + duration;
  bool active(double t) => t >= start && t < end;
  factory TabNote.fromJson(Map<String, dynamic> j) => TabNote(
    id: j['id'],
    midi: j['midi'],
    start: (j['start'] as num).toDouble(),
    duration: (j['duration'] as num).toDouble(),
    stringNumber: j['string'] ?? 0,
    fret: j['fret'] ?? 0,
    technique: j['technique'] ?? '',
    source: j['source'] ?? 'authored',
    staffStep: j['staffStep'] ?? 0,
    accidental: j['accidental'] ?? '',
    beam: j['beam'] ?? '',
    tie: j['tie'] ?? '',
    writtenMidi: j['writtenMidi'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'midi': midi,
    'start': start,
    'duration': duration,
    'string': stringNumber,
    'fret': fret,
    'technique': technique,
    'source': source,
    'staffStep': staffStep,
    'writtenMidi': writtenMidi,
    'accidental': accidental,
    'beam': beam,
    'tie': tie,
  };
}

class TabScore {
  final String id, title, attribution;
  final int program;
  final double duration;
  final List<TabNote> notes;
  final List<double> rests;
  final bool guitar, staff;
  final Map<String, dynamic> provenance;
  const TabScore({
    required this.id,
    required this.title,
    required this.notes,
    required this.duration,
    this.program = 0,
    this.guitar = false,
    this.staff = false,
    this.attribution = 'Authored synthetic study',
    this.rests = const [],
    this.provenance = const {},
  });
  factory TabScore.fromJson(Map<String, dynamic> j) => TabScore(
    id: j['id'],
    title: j['title'],
    notes: [for (final n in j['notes']) TabNote.fromJson(n)],
    duration: (j['duration'] as num).toDouble(),
    program: j['program'],
    guitar: j['guitar'],
    staff: j['staff'],
    attribution: j['attribution'],
    rests: [for (final r in j['rests'] ?? []) (r as num).toDouble()],
    provenance: j['provenance'] ?? {},
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes.map((n) => n.toJson()).toList(),
    'duration': duration,
    'program': program,
    'guitar': guitar,
    'staff': staff,
    'attribution': attribution,
    'rests': rests,
    'provenance': provenance,
  };
  void validate() {
    final ids = <String>{};
    for (final n in notes) {
      if (!ids.add(n.id) ||
          n.start < 0 ||
          n.duration <= 0 ||
          n.end > duration + .001 ||
          n.midi < 0 ||
          n.midi > 127) {
        throw FormatException('Invalid note ${n.id} in $id');
      }
      if (n.stringNumber > 0 && n.source == 'authored') {
        const tuning = [0, 64, 59, 55, 50, 45, 40];
        if (n.stringNumber > 6 ||
            n.fret < 0 ||
            tuning[n.stringNumber] + n.fret != n.midi) {
          throw FormatException('Invalid string/fret for ${n.id}');
        }
        for (final other in notes) {
          if (other.id != n.id &&
              other.source == 'authored' &&
              other.stringNumber == n.stringNumber &&
              n.start < other.end - .0001 &&
              other.start < n.end - .0001) {
            throw FormatException(
              'Overlapping authored string ${n.stringNumber}: ${n.id}, ${other.id}',
            );
          }
        }
      }
    }
  }
}

/// Pitch displacement is separate from string/fret identity and score time.
double techniqueSemitones(TabNote n, double scoreTime, {double scale = 1}) {
  final u = ((scoreTime - n.start) / n.duration).clamp(0.0, 1.0);
  final v = switch (n.technique) {
    'bend' =>
      u < .3
          ? 2 * u / .3
          : u < .65
          ? 2.0
          : 2 * (1 - u) / .35,
    'vibrato' => .28 * math.sin(u * math.pi * 18) * math.min(1, u * 8),
    'bar-dip' => -2 * math.sin(math.pi * u),
    _ => 0.0,
  };
  return v * scale;
}

class PerformedEvent {
  final TabNote expected;
  final double start, duration, bendScale;
  final String result;
  const PerformedEvent(
    this.expected,
    this.start,
    this.duration,
    this.result, {
    this.bendScale = 1,
  });
  double get end => start + duration;
}

List<PerformedEvent> performedEvents(TabScore fixture, FeedbackMode mode) {
  if (mode == FeedbackMode.off) return [];
  return [
    for (var i = 0; i < fixture.notes.length; i++)
      if (mode != FeedbackMode.imperfect || i % 7 != 5)
        PerformedEvent(
          fixture.notes[i],
          math.max(
            0,
            fixture.notes[i].start +
                (mode == FeedbackMode.imperfect
                    ? switch (i % 7) {
                        1 => -.1,
                        2 => .1,
                        _ => 0.0,
                      }
                    : 0),
          ),
          fixture.notes[i].duration,
          mode == FeedbackMode.imperfect
              ? (fixture.notes[i].technique == 'bend'
                    ? 'bend undershoot'
                    : switch (i % 7) {
                        1 => 'early',
                        2 => 'late',
                        _ => 'on time',
                      })
              : 'on time',
          bendScale:
              mode == FeedbackMode.imperfect &&
                  fixture.notes[i].technique == 'bend'
              ? .65
              : 1,
        ),
  ];
}

String feedbackFor(
  TabNote n,
  double t,
  List<PerformedEvent> events,
  FeedbackMode mode,
) {
  if (mode == FeedbackMode.off) return '';
  final matching = events.where((e) => e.expected.id == n.id);
  if (matching.isEmpty) return t >= n.end ? 'missed' : '';
  final e = matching.first;
  return t >= e.start ? e.result : '';
}

/// Stable pitch spelling for this bounded fixture renderer. Guitar is written
/// an octave above sounding pitch; imported scores are not re-engraved here.
int trebleStep(int writtenMidi) {
  const diatonic = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];
  final octave = writtenMidi ~/ 12 - 1;
  return (octave - 4) * 7 +
      diatonic[writtenMidi % 12] -
      2; // E4 = bottom staff line.
}
