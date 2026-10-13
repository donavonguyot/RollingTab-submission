import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_melty_soundfont/soundfont.dart';
import 'package:dart_melty_soundfont/synthesizer.dart';
import 'package:dart_melty_soundfont/synthesizer_settings.dart';

const sampleRate = 44100;
const quantum = 64;

double canonicalSpeed(double value) {
  if (!value.isFinite ||
      value < .25 ||
      value > 1.5 ||
      (value * 100 - (value * 100).round()).abs() > 1e-8) {
    throw ArgumentError('Choose a whole percentage from 25% to 150%.');
  }
  return (value * 100).round() / 100;
}

/// No Player or Flutter model dependencies. Times and curves use score seconds.
class AudioNote {
  final String id;
  final int midi, channel;
  final double start, end;
  final bool tremolo;
  final double Function(double)? bend;
  const AudioNote({
    required this.id,
    required this.midi,
    required this.channel,
    required this.start,
    required this.end,
    this.tremolo = false,
    this.bend,
  });
}

class Passage {
  final List<AudioNote> notes;
  final int program;
  final double start, end;
  Passage({
    required List<AudioNote> notes,
    required this.program,
    required this.start,
    required this.end,
  }) : notes = List.unmodifiable(
         [...notes.where((n) => n.start < end && n.end > start)]
           ..sort((a, b) => a.start.compareTo(b.start)),
       ) {
    if (!start.isFinite ||
        !end.isFinite ||
        start < 0 ||
        end <= start ||
        end - start > 60.000001) {
      throw ArgumentError('Invalid passage');
    }
  }
}

class FrameSpan {
  final int frame, frames, wraps;
  final double score, speed;
  const FrameSpan(this.frame, this.frames, this.score, this.speed, this.wraps);
  double at(double played) =>
      score + (played - frame).clamp(0, frames) / sampleRate * speed;
}

/// Amortized onset cursor; work per quantum depends on active notes, not score size.
class SynthCore {
  final Synthesizer synth;
  final Passage passage;
  final active = <String, AudioNote>{};
  final phases = <String, int>{};
  final keyOwners = <int, int>{};
  int cursor = 0, wraps = 0, attacks = 0;
  double time = 0, speed;
  bool loop;
  final _left = Float32List(quantum), _right = Float32List(quantum);
  SynthCore(SoundFont font, this.passage, {this.speed = 1, this.loop = true})
    : synth = Synthesizer.load(
        font,
        SynthesizerSettings(
          sampleRate: sampleRate,
          blockSize: quantum,
          maximumPolyphony: 128,
          enableReverbAndChorus: false,
        ),
      ) {
    canonicalSpeed(speed);
    beginReconstruction(passage.start);
  }
  int get voices => synth.activeVoiceCount();
  double get origin =>
      passage.notes.fold(passage.start, (v, n) => math.min(v, n.start));
  void beginReconstruction(double target) {
    synth.reset();
    for (var ch = 0; ch < 16; ch++) {
      synth.processMidiMessage(
        channel: ch,
        command: 0xC0,
        data1: passage.program,
        data2: 0,
      );
    }
    active.clear();
    phases.clear();
    keyOwners.clear();
    cursor = 0;
    // Include notes ending before target so their natural release tails survive seeks.
    time = origin;
  }

  void _events() {
    for (final n in active.values.toList()) {
      if (n.end <= time + 1e-10) {
        active.remove(n.id);
        phases.remove(n.id);
        final key = n.channel * 128 + n.midi;
        final count = (keyOwners[key] ?? 1) - 1;
        keyOwners[key] = count;
        if (count == 0) synth.noteOff(channel: n.channel, key: n.midi);
      }
    }
    while (cursor < passage.notes.length &&
        passage.notes[cursor].start <= time + 1e-10) {
      final n = passage.notes[cursor++];
      if (n.end <= time) continue;
      active[n.id] = n;
      final key = n.channel * 128 + n.midi;
      keyOwners[key] = (keyOwners[key] ?? 0) + 1;
      _bend(n);
      synth.noteOn(channel: n.channel, key: n.midi, velocity: 82);
      attacks++;
      phases[n.id] = ((time - n.start) * 8).floor();
    }
    for (final n in active.values) {
      _bend(n);
      final phase = ((time - n.start) * 8).floor();
      if (n.tremolo && phases[n.id] != phase) {
        synth.noteOff(channel: n.channel, key: n.midi);
        synth.noteOn(channel: n.channel, key: n.midi, velocity: 82);
        attacks++;
        phases[n.id] = phase;
      }
    }
  }

  void _bend(AudioNote n) {
    final value = (8192 + (n.bend?.call(time) ?? 0) / 2 * 8191).round().clamp(
      0,
      16383,
    );
    synth.processMidiMessage(
      channel: n.channel,
      command: 0xE0,
      data1: value & 127,
      data2: value >> 7,
    );
  }

  /// At most 64 audio frames per call; callers can yield/cancel between batches.
  void prerollStep(double target) {
    final count = math.min(
      quantum,
      ((target - time) / speed * sampleRate).round(),
    );
    if (count <= 0) {
      time = target;
      return;
    }
    _events();
    synth.render(
      Float32List.sublistView(_left, 0, count),
      Float32List.sublistView(_right, 0, count),
    );
    time += count / sampleRate * speed;
    if ((time - target).abs() < speed / sampleRate) time = target;
  }

  void _wrap() {
    final target = passage.start + (time - passage.end);
    beginReconstruction(target);
    while (time < target - 1e-10) {
      prerollStep(target);
    }
    wraps++;
  }

  List<FrameSpan> render(Float32List left, Float32List right, int frame) {
    final spans = <FrameSpan>[];
    var offset = 0;
    while (offset < left.length) {
      if (time >= passage.end - 1e-10) {
        if (loop) {
          _wrap();
        } else {
          left.fillRange(offset, left.length, 0);
          right.fillRange(offset, right.length, 0);
          break;
        }
      }
      final untilEnd = math.max(
        1,
        ((passage.end - time) / speed * sampleRate).ceil(),
      );
      final count = math.min(quantum, math.min(left.length - offset, untilEnd));
      _events();
      synth.render(
        Float32List.sublistView(_left, 0, count),
        Float32List.sublistView(_right, 0, count),
      );
      spans.add(FrameSpan(frame + offset, count, time, speed, wraps));
      for (var j = 0; j < count; j++) {
        // Fixed gain; no per-passage normalization or gain pumping.
        left[offset + j] = (_left[j] * .7).clamp(-.98, .98);
        right[offset + j] = (_right[j] * .7).clamp(-.98, .98);
      }
      time += count / sampleRate * speed;
      offset += count;
    }
    return spans;
  }
}
