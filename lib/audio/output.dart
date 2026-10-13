import 'package:flutter/services.dart';
import 'package:rollingtab_audio/rollingtab_audio.dart';

import '../model/music.dart';

export 'package:rollingtab_audio/rollingtab_audio.dart' show canonicalSpeed;

abstract class AudioPort {
  void unlock();
  Future<void> initialize(
    TabScore score,
    double start,
    double end,
    double position,
    double speed,
    bool loop,
    FeedbackMode feedback,
    void Function(double) progress,
  );
  Future<void> play();
  Future<void> pause();
  Future<void> seek(double position, {required bool resume});
  void speed(double speed);
  void loop(bool enabled);
  void cancel();
  double get position;
  bool get alive;
  int get voices;
  int get wraps;
  Map<String, dynamic> get diagnostics;
  Future<void> dispose();
}

class ContinuousAudio implements AudioPort {
  final engine = ContinuousEngine();
  Future<ByteData>? _font;
  int _generation = 0;
  @override
  void unlock() => engine.unlock();
  @override
  Future<void> initialize(
    TabScore score,
    double start,
    double end,
    double position,
    double speed,
    bool loop,
    FeedbackMode feedback,
    void Function(double) progress,
  ) async {
    final token = ++_generation;
    final data = await (_font ??= rootBundle.load(
      'assets/soundfont/GeneralUser_GS.sf2',
    ));
    if (token != _generation) return;
    final events = performedEvents(
      score,
      feedback == FeedbackMode.off ? FeedbackMode.correct : feedback,
    );
    // Unassigned guidance still sounds; reserve string channels for independent bends.
    const otherChannels = [0, 7, 8, 10, 11, 12, 13, 14, 15];
    final notes = [
      for (var i = 0; i < events.length; i++)
        AudioNote(
          id: events[i].expected.id,
          midi: events[i].expected.midi,
          channel: events[i].expected.stringNumber > 0
              ? events[i].expected.stringNumber
              : otherChannels[i % otherChannels.length],
          start: events[i].start,
          end: events[i].end,
          tremolo: events[i].expected.technique == 'tremolo',
          bend: (t) => techniqueSemitones(
            events[i].expected,
            events[i].expected.start + t - events[i].start,
            scale: events[i].bendScale,
          ),
        ),
    ];
    await engine.initialize(
      data,
      Passage(notes: notes, program: score.program, start: start, end: end),
      position,
      speed,
      loop,
      progress,
    );
  }

  @override
  Future<void> play() => engine.play();
  @override
  Future<void> pause() => engine.pause();
  @override
  Future<void> seek(double position, {required bool resume}) =>
      engine.seek(position, resume: resume);
  @override
  void speed(double value) => engine.speed(value);
  @override
  void loop(bool enabled) => engine.loop(enabled);
  @override
  void cancel() {
    _generation++;
    engine.cancel();
  }

  @override
  double get position => engine.position;
  @override
  bool get alive => engine.running && !engine.ended;
  @override
  int get voices => engine.voices;
  @override
  int get wraps => engine.wraps;
  @override
  Map<String, dynamic> get diagnostics => engine.diagnostics;
  void startCapture() => engine.startCapture();
  Future<void> stopCapture() => engine.stopCapture();
  Uint8List? get capturedPcm => engine.capturedPcm;
  Map<String, dynamic>? get captureResult => engine.captureResult;
  @override
  Future<void> dispose() {
    _generation++;
    return engine.dispose();
  }
}
