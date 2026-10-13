import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:flutter/services.dart';

import 'core.dart';
import 'sink.dart';

PcmSink createSink() => NativePcmSink();

class NativePcmSink implements PcmSink {
  int generation = 0, submitted = 0, underruns = 0, lateCallbacks = 0;
  static const activity = MethodChannel("rollingtab/audioActivity");
  Future<void> active(bool value) async {
    try {
      await activity.invokeMethod<void>("setActive", value);
    } on MissingPluginException {
      /* Other hosts may supply their own policy. */
    }
  }

  double reported = 0, gapSeconds = 0;
  final clock = Stopwatch();
  bool started = false;
  final pending = <Future<void>>{};
  String? error;
  @override
  void unlock() {}
  @override
  Future<void> start(RenderPcm render) async {
    error = null;
    final token = ++generation;
    submitted = 0;
    reported = 0;
    started = false;
    await active(true);
    await FlutterPcmSound.setLogLevel(LogLevel.none);
    await FlutterPcmSound.setup(sampleRate: sampleRate, channelCount: 2);
    await FlutterPcmSound.setFeedThreshold(2048);
    clock
      ..reset()
      ..start();
    FlutterPcmSound.setFeedCallback((remaining) {
      if (token != generation) return;
      try {
        final overdue =
            clock.elapsedMicroseconds / 1e6 -
            (submitted - reported) / sampleRate;
        if (started && overdue > .008) lateCallbacks++;
        // Trust the plugin's measured remaining count for refill sizing. An
        // elapsed-time estimate must never feed back into queue allocation.
        if (started && remaining == 0) {
          underruns++;
          gapSeconds += math.max(0, overdue);
        }
        reported = (submitted - remaining).toDouble();
        clock
          ..reset()
          ..start();
        var count = remaining;
        while (count < 2560 && token == generation) {
          final l = Float32List(512), r = Float32List(512);
          render(l, r, submitted);
          final data = ByteData(512 * 4);
          for (var i = 0; i < 512; i++) {
            data.setInt16(
              i * 4,
              (l[i] * 32767).round().clamp(-32767, 32767),
              Endian.little,
            );
            data.setInt16(
              i * 4 + 2,
              (r[i] * 32767).round().clamp(-32767, 32767),
              Endian.little,
            );
          }
          // Submit without yielding inside the callback. A low-water callback
          // arriving before acknowledgement must not be discarded (RP pattern).
          submitted += 512;
          late final Future<void> feed;
          feed = FlutterPcmSound.feed(PcmArrayInt16(bytes: data))
              .catchError((Object e) {
                if (token == generation) error = '$e';
              })
              .whenComplete(() => pending.remove(feed));
          pending.add(feed);
          count += 512;
          started = true;
        }
      } catch (e) {
        error = '$e';
      }
    });
    FlutterPcmSound.onFeedSamplesCallback?.call(0);
  }

  @override
  double get playedFrames =>
      (reported + clock.elapsedMicroseconds / 1e6 * sampleRate)
          .clamp(0, submitted)
          .toDouble();
  @override
  Future<void> stop() async {
    generation++;
    FlutterPcmSound.setFeedCallback(null);
    await Future.wait(pending.toList());
    await FlutterPcmSound.release();
    await active(false);
    clock.stop();
    submitted = 0;
    reported = 0;
  }

  @override
  Future<void> dispose() => stop();
  @override
  Map<String, dynamic> get diagnostics => {
    'backend': 'flutter_pcm_sound / Core Audio',
    'clock': 'estimated from PCM remaining frames + monotonic time',
    'queueMs': (submitted - playedFrames) / sampleRate * 1000,
    'underruns': underruns,
    'lateCallbacksEstimate': lateCallbacks,
    'gapSecondsEstimate': gapSeconds,
    'error': error,
    'pendingSubmissions': pending.length,
  };
}
