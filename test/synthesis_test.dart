import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_melty_soundfont/soundfont.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab_audio/rollingtab_audio.dart';
import 'package:rollingtab/model/music.dart';

void main() {
  final font = SoundFont.fromByteData(
    ByteData.sublistView(
      File('assets/soundfont/GeneralUser_GS.sf2').readAsBytesSync(),
    ),
  );
  SynthCore core({
    double start = 0,
    double end = 2,
    double speed = 1,
    List<AudioNote>? notes,
  }) => SynthCore(
    font,
    Passage(
      start: start,
      end: end,
      program: 24,
      notes:
          notes ??
          [const AudioNote(id: 'a', midi: 64, channel: 1, start: 0, end: 2)],
    ),
    speed: speed,
    loop: false,
  );
  Float32List render(SynthCore c, int count) {
    final l = Float32List(count), r = Float32List(count);
    c.render(l, r, 0);
    return l;
  }

  test('Live speed leaves held voice and pitch waveform unchanged', () {
    for (final speed in [.25, .73, 1.0, 1.5]) {
      final a = core(), b = core();
      render(a, 4096);
      render(b, 4096);
      b.speed = speed;
      expect(render(a, 4096), render(b, 4096));
      expect(b.attacks, 1);
      expect(b.time, closeTo(4096 / 44100 * (1 + speed), 1e-8));
    }
  });
  test('Silent preroll preserves envelope and phase into a sustain', () {
    final a = core(), b = core(start: .5);
    final whole = render(a, 44100);
    while (b.time < .5 - 1e-10) {
      b.prerollStep(.5);
    }
    final cut = render(b, 22050);
    double dot = 0, xx = 0, yy = 0;
    for (var i = 0; i < cut.length; i++) {
      final x = whole[i + 22050], y = cut[i];
      dot += x * y;
      xx += x * x;
      yy += y * y;
    }
    expect(dot / math.sqrt(xx * yy), greaterThan(.999));
  });
  test('Repeated notes, overlap owners and tremolo retain attacks', () {
    final c = core(
      notes: [
        const AudioNote(id: 'held', midi: 64, channel: 1, start: 0, end: 1.5),
        const AudioNote(
          id: 'repeat',
          midi: 64,
          channel: 1,
          start: .25,
          end: .5,
        ),
        const AudioNote(
          id: 'pick',
          midi: 59,
          channel: 2,
          start: 0,
          end: 1,
          tremolo: true,
        ),
      ],
    );
    render(c, 44100);
    expect(c.active.keys, contains('held'));
    expect(c.attacks, 10);
    render(c, 44100);
    expect(c.active, isEmpty);
  });
  test(
    'Technique curves independent of channels and immutable note identity',
    () {
      for (final kind in ['bend', 'vibrato', 'bar-dip']) {
        final n = TabNote(
          id: kind,
          midi: 64,
          start: 0,
          duration: 1,
          technique: kind,
        );
        final c = core(
          notes: [
            AudioNote(
              id: kind,
              midi: 64,
              channel: 1,
              start: 0,
              end: 1,
              bend: (t) => techniqueSemitones(n, t),
            ),
            const AudioNote(
              id: 'steady',
              midi: 59,
              channel: 2,
              start: 0,
              end: 1,
            ),
          ],
        );
        render(c, 20000);
        expect(c.active.keys, containsAll([kind, 'steady']));
        expect(c.attacks, 2);
        expect(c.synth.channels[1].pitchBend, isNot(0));
        expect(c.synth.channels[2].pitchBend, 0);
      }
    },
  );
  test('Loop resets voices and carries fractional overshoot', () {
    final c = core(end: .123)..loop = true;
    render(c, 44100);
    expect(c.wraps, 8);
    expect(c.time, closeTo(.016, 2 / 44100));
    expect(c.active.length, 1);
  });
  test('Passage validation precedes rendering', () {
    expect(() => core(end: 61), throwsArgumentError);
    expect(() => core(start: 2, end: 1), throwsArgumentError);
  });
}
