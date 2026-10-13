import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab/model/music.dart';
import 'package:rollingtab/model/projection.dart';
import 'package:rollingtab/model/voicing.dart';

TabScore study(String id) => TabScore.fromJson(
  jsonDecode(File('assets/fixtures/$id.json').readAsStringSync()),
);
TabNote note(
  String id,
  int midi,
  double at,
  double duration, {
  int string = 0,
  int fret = 0,
  String source = 'inferred',
}) => TabNote(
  id: id,
  midi: midi,
  start: at,
  duration: duration,
  stringNumber: string,
  fret: fret,
  source: source,
);
TabScore score(List<TabNote> notes) => TabScore(
  id: 'test',
  title: 'Test',
  notes: notes,
  duration: 10,
  guitar: true,
);
void main() {
  test('All authored studies have valid non-conflicting string positions', () {
    for (final id in [
      'guitar-voicings',
      'guitar-techniques',
      'guitar-movement',
      'guitar-phrase',
      'guitar-density',
    ]) {
      study(id).validate();
    }
  });
  test(
    'Em to Cmaj7 keeps four sounding IDs and introduces only the C bass',
    () {
      final s = VoicingStudy(study('guitar-voicings'));
      final before = s.at(2.5, 2);
      expect(before.sounding.where(before.continues).length, 4);
      expect(
        before.target
            .where((n) => !before.sounding.any((x) => x.id == n.id))
            .map((n) => n.id),
        ['c-bass'],
      );
      final after = s.at(3.05, 2);
      expect(after.released.map((n) => n.stringNumber).toSet(), {5, 6});
    },
  );
  test('Preview does not make an upcoming note sound early', () {
    final s = VoicingStudy(study('guitar-voicings'));
    expect(s.at(2.5, 2).sounding.any((n) => n.id == 'c-bass'), false);
    expect(s.at(3, 2).sounding.any((n) => n.id == 'c-bass'), true);
  });
  test(
    'An arpeggio can prepare a full authored shape with one sounding note',
    () {
      final f = VoicingStudy(study('guitar-movement')).at(1.01, 2);
      expect(f.sounding.length, 1);
      expect(f.prepared.length, 6);
    },
  );
  test('Repeated attacks retain position but change note identity', () {
    final s = VoicingStudy(study('guitar-movement'));
    final a = s.at(4.1, 2), b = s.at(4.55, 2);
    expect(
      a.sounding.map((n) => (n.stringNumber, n.fret)),
      b.sounding.map((n) => (n.stringNumber, n.fret)),
    );
    expect(a.sounding.first.id, isNot(b.sounding.first.id));
    expect(b.arrival, lessThan(1));
  });
  test('Melody changes preserve bass and inner voice', () {
    final s = VoicingStudy(study('guitar-movement'));
    final f = s.at(6.8, 2);
    expect(f.sounding.where(f.continues).map((n) => n.id).toSet(), {
      'held-bass',
      'held-inner',
    });
  });
  test('Inference assigns simultaneous pitches to distinct strings', () {
    final result = projectGuitar(
      score([note('a', 64, 1, 2), note('b', 64, 1, 2), note('c', 64, 1, 2)]),
    );
    expect(
      result.notes
          .where((n) => n.stringNumber > 0)
          .map((n) => n.stringNumber)
          .toSet()
          .length,
      3,
    );
  });
  test('A sustain reserves its string across later onsets', () {
    final result = projectGuitar(
      score([
        note('held', 64, 0, 4, string: 1, fret: 0, source: 'authored'),
        note('later', 64, 1, 1),
      ]),
    );
    expect(result.notes.first.stringNumber, 1);
    expect(result.notes.last.stringNumber, isNot(1));
  });
  test('Conflicting authored positions are withheld rather than moved', () {
    final result = projectGuitar(
      score([
        note('a', 64, 0, 4, string: 1, source: 'authored'),
        note('b', 65, 1, 1, string: 1, fret: 1, source: 'authored'),
      ]),
    );
    expect(result.notes.last.stringNumber, 0);
    expect(result.provenance['diagnostics'], isNotEmpty);
  });
  test('Authored 24th-fret positions remain authored', () {
    final result = projectGuitar(
      score([note('upper', 88, 0, 1, string: 1, fret: 24, source: 'authored')]),
    );
    expect(result.notes.single.fret, 24);
    expect(result.notes.single.source, 'authored');
  });
  test('Valid authored positions survive inference', () {
    final result = projectGuitar(
      score([note('a', 64, 1, 2, string: 2, fret: 5, source: 'authored')]),
    );
    expect(result.notes.single.stringNumber, 2);
    expect(result.notes.single.fret, 5);
  });
  test('Out-of-range notes remain audible data with no asserted position', () {
    final result = projectGuitar(score([note('low', 20, 0, 1)]));
    expect(result.notes.single.midi, 20);
    expect(result.notes.single.stringNumber, 0);
  });
  test('Seeking reconstructs identical state and preparation lead', () {
    final s = VoicingStudy(study('guitar-voicings'));
    final first = s.at(2.8, 2).toJson();
    s.at(10, 4);
    expect(s.at(2.8, 2).toJson(), first);
    expect(s.at(1.5, .5).preview, 0);
  });
  test('Preparation beat count respects score tempo changes', () {
    final fixture = TabScore.fromJson({
      ...score([note('a', 64, 3, 1)]).toJson(),
      'provenance': {
        'tempoMap': [
          {'seconds': 0, 'bpm': 60},
          {'seconds': 2, 'bpm': 120},
        ],
      },
    });
    final s = VoicingStudy(fixture);
    expect(s.beatsAt(3), 4);
    expect(s.at(2.5, 2).beatsUntil, 1);
  });
  test('Technique pitch curves separate bend, vibrato and bar dip', () {
    TabNote n(String t) =>
        TabNote(id: t, midi: 64, start: 0, duration: 4, technique: t);
    expect(techniqueSemitones(n('bend'), 2), 2);
    expect(techniqueSemitones(n('bar-dip'), 2), -2);
    expect(techniqueSemitones(n('tremolo'), 2), 0);
    expect(techniqueSemitones(n('vibrato'), .5).abs(), lessThanOrEqualTo(.28));
  });
}
