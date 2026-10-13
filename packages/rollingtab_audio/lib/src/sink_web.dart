import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'core.dart';
import 'sink.dart';

PcmSink createSink() => WebPcmSink();

class WebPcmSink implements PcmSink {
  web.AudioContext? context;
  Timer? timer;
  final sources = <web.AudioBufferSourceNode>[];
  final spans = <(double, int)>[];
  int submitted = 0, underruns = 0;
  double next = 0, gapSeconds = 0;
  String? error;
  @override
  void unlock() {
    context ??= web.AudioContext();
    context!.resume().toDart.catchError((Object e) {
      error = '$e';
      return null;
    });
  }

  @override
  Future<void> start(RenderPcm render) async {
    error = null;
    unlock();
    await context!.resume().toDart;
    submitted = 0;
    spans.clear();
    next = context!.currentTime + .01;
    void pump() {
      try {
        final now = context!.currentTime;
        if (next < now) {
          underruns++;
          gapSeconds += now - next;
          next = now + .01;
        }
        while (next < now + .06) {
          final l = Float32List(512), r = Float32List(512);
          render(l, r, submitted);
          final buffer = context!.createBuffer(2, 512, sampleRate);
          buffer.copyToChannel(l.toJS, 0);
          buffer.copyToChannel(r.toJS, 1);
          final source = context!.createBufferSource()..buffer = buffer;
          source.connect(context!.destination);
          source.onended = ((web.Event _) {
            source.disconnect();
            sources.remove(source);
          }).toJS;
          sources.add(source);
          spans.add((next, submitted));
          source.start(next);
          next += 512 / sampleRate;
          submitted += 512;
        }
        while (spans.length > 1 && spans[1].$1 <= now) {
          spans.removeAt(0);
        }
      } catch (e) {
        error = '$e';
        timer?.cancel();
      }
    }

    pump();
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) => pump());
  }

  @override
  double get playedFrames {
    if (spans.isEmpty || context == null) return 0;
    final now = context!.currentTime;
    var s = spans.first;
    for (final v in spans) {
      if (v.$1 <= now) {
        s = v;
      } else {
        break;
      }
    }
    return (s.$2 + math.max(0, now - s.$1) * sampleRate)
        .clamp(0, submitted)
        .toDouble();
  }

  @override
  Future<void> stop() async {
    timer?.cancel();
    timer = null;
    for (final s in sources.toList()) {
      s.stop();
      s.disconnect();
    }
    sources.clear();
    spans.clear();
    submitted = 0;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await context?.close().toDart;
    context = null;
  }

  @override
  Map<String, dynamic> get diagnostics => {
    'backend': 'Web Audio scheduled PCM',
    'clock': 'AudioContext.currentTime',
    'queueMs': (submitted - playedFrames) / sampleRate * 1000,
    'underruns': underruns,
    'gapSeconds': gapSeconds,
    'scheduledSources': sources.length,
    'error': error,
    'state': context?.state,
  };
}
