import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_melty_soundfont/soundfont.dart';

import 'core.dart';
import 'sink.dart';
import 'sink_native.dart' if (dart.library.js_interop) 'sink_web.dart';

/// Serial output ownership, generation-checked reconstruction and audio-time mapping.
class ContinuousEngine {
  final PcmSink sink;
  ContinuousEngine({PcmSink? sink}) : sink = sink ?? createSink();
  SoundFont? font;
  SynthCore? core;
  final spans = <FrameSpan>[];
  Future<void> _queue = Future.value();
  int generation = 0;
  bool running = false;
  double heldPosition = 0,
      requestedSpeed = 1,
      lastControlDelayMs = 0,
      maxControlDelayMs = 0;
  Stopwatch? _speedRequest;
  BytesBuilder? _capture;
  Uint8List? capturedPcm;
  Map<String, dynamic>? captureResult;
  double _square = 0, _peak = 0;
  int _samples = 0;

  void unlock() => sink.unlock();
  Future<void> _serial(Future<void> Function() work) {
    final future = _queue.then((_) => work());
    _queue = future.catchError((Object _) {});
    return future;
  }

  Future<void> initialize(
    ByteData data,
    Passage passage,
    double position,
    double speed,
    bool loop,
    void Function(double) progress,
  ) {
    final token = ++generation;
    running = false;
    heldPosition = position;
    lastControlDelayMs = 0;
    requestedSpeed = canonicalSpeed(speed);
    return _serial(() async {
      await sink.stop();
      if (token != generation) return;
      font ??= SoundFont.fromByteData(data);
      final candidate = SynthCore(
        font!,
        passage,
        speed: requestedSpeed,
        loop: loop,
      );
      await _reconstruct(candidate, position, token, progress);
      if (token != generation) return;
      core = candidate;
      spans.clear();
    });
  }

  Future<void> _reconstruct(
    SynthCore candidate,
    double position,
    int token,
    void Function(double) progress,
  ) async {
    candidate.beginReconstruction(position);
    final total = position - candidate.time;
    while (candidate.time < position - 1e-10) {
      if (token != generation) return;
      for (var i = 0; i < 64 && candidate.time < position - 1e-10; i++) {
        candidate.prerollStep(position);
      }
      progress(total <= 0 ? 1 : 1 - (position - candidate.time) / total);
      await Future<void>.delayed(Duration.zero);
    }
    progress(1);
  }

  Future<void> play() {
    unlock();
    final token = generation;
    return _serial(() async {
      if (token != generation || core == null || running) return;
      spans.clear();
      running = true;
      try {
        await sink.start(_render);
      } catch (e) {
        running = false;
        rethrow;
      }
    });
  }

  void _render(Float32List l, Float32List r, int first) {
    final c = core!;
    if (c.speed != requestedSpeed) {
      c.speed = requestedSpeed;
      lastControlDelayMs =
          (_speedRequest?.elapsedMicroseconds ?? 0) / 1000 +
          (first - sink.playedFrames).clamp(0, double.infinity) /
              sampleRate *
              1000;
      maxControlDelayMs = math.max(maxControlDelayMs, lastControlDelayMs);
      _speedRequest = null;
    }
    spans.addAll(c.render(l, r, first));
    final played = sink.playedFrames;
    while (spans.length > 1 && spans[1].frame <= played) {
      spans.removeAt(0);
    }
    if (_capture != null && _capture!.length < sampleRate * 4 * 30) {
      final bytes = ByteData(l.length * 4);
      for (var i = 0; i < l.length; i++) {
        bytes.setInt16(i * 4, (l[i] * 32767).round(), Endian.little);
        bytes.setInt16(i * 4 + 2, (r[i] * 32767).round(), Endian.little);
        _square += l[i] * l[i] + r[i] * r[i];
        _samples += 2;
        _peak = math.max(_peak, math.max(l[i].abs(), r[i].abs()));
      }
      _capture!.add(bytes.buffer.asUint8List());
    }
  }

  FrameSpan? get currentSpan {
    if (spans.isEmpty) return null;
    final frame = sink.playedFrames;
    var span = spans.first;
    for (final s in spans) {
      if (s.frame <= frame) {
        span = s;
      } else {
        break;
      }
    }
    return span;
  }

  double get position => !running || currentSpan == null
      ? heldPosition
      : currentSpan!
            .at(sink.playedFrames)
            .clamp(core!.passage.start, core!.passage.end);
  int get wraps => currentSpan?.wraps ?? 0;
  bool get ended =>
      core != null &&
      !core!.loop &&
      position >= core!.passage.end - 1 / sampleRate;
  int get voices => core?.voices ?? 0;
  Future<void> pause() => seek(position, resume: false);
  Future<void> seek(double target, {required bool resume}) {
    final token = ++generation;
    heldPosition = target;
    running = false;
    return _serial(() async {
      await sink.stop();
      if (token != generation || core == null) return;
      final c = core!;
      c.speed = requestedSpeed;
      await _reconstruct(c, target, token, (_) {});
      if (token != generation) return;
      spans.clear();
      if (resume) {
        running = true;
        await sink.start(_render);
      }
    });
  }

  void speed(double value) {
    requestedSpeed = canonicalSpeed(value);
    _speedRequest = Stopwatch()..start();
  }

  void loop(bool enabled) {
    core?.loop = enabled;
  }

  void cancel() {
    generation++;
    heldPosition = position;
    running = false;
    unawaited(
      _serial(() async {
        await sink.stop();
        spans.clear();
        core = null;
      }),
    );
  }

  Map<String, dynamic> get diagnostics => {
    ...sink.diagnostics,
    'voices': voices,
    'position': position,
    'wraps': wraps,
    'requestedSpeed': requestedSpeed,
    'audibleSpeed': currentSpan?.speed ?? requestedSpeed,
    'lastSpeedDelayMs': lastControlDelayMs,
    'maxSpeedDelayMs': maxControlDelayMs,
    'retainedClockSpans': spans.length,
    'running': running,
  };
  void startCapture() {
    _capture = BytesBuilder(copy: false);
    capturedPcm = null;
    captureResult = null;
    _square = 0;
    _peak = 0;
    _samples = 0;
  }

  Future<void> stopCapture() async {
    capturedPcm = _capture?.takeBytes();
    _capture = null;
    captureResult = {
      'source': 'Scheduled synthesis PCM; not physical speaker loopback',
      'samples': _samples,
      'seconds': _samples / (sampleRate * 2),
      'rms': _samples == 0 ? 0 : math.sqrt(_square / _samples),
      'peak': _peak,
    };
  }

  Future<void> dispose() {
    generation++;
    running = false;
    return _serial(sink.dispose);
  }
}
