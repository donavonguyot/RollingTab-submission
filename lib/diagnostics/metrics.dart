import 'dart:math' as math;

import 'package:flutter/scheduler.dart';

class LabMetrics {
  final clock = Stopwatch()..start();
  final List<double> intervals = [], build = [], raster = [], total = [];
  int? previous;
  int stalls = 0;
  bool awaitingStall = false;
  final List<double> deliberateIntervals = [];
  Map<String, dynamic>? collected;
  void injectStall() {
    stalls++;
    awaitingStall = true;
  }

  void reset() {
    intervals.clear();
    build.clear();
    raster.clear();
    total.clear();
    previous = null;
    stalls = 0;
    awaitingStall = false;
    deliberateIntervals.clear();
    collected = null;
    clock.reset();
  }

  void frame() {
    final now = clock.elapsedMicroseconds;
    if (previous != null && intervals.length < 120000) {
      final interval = (now - previous!) / 1000;
      if (awaitingStall) {
        deliberateIntervals.add(interval);
        awaitingStall = false;
      } else {
        intervals.add(interval);
      }
    }
    previous = now;
  }

  void timings(List<FrameTiming> times) {
    for (final t in times) {
      if (build.length >= 120000) break;
      build.add(t.buildDuration.inMicroseconds / 1000);
      raster.add(t.rasterDuration.inMicroseconds / 1000);
      total.add(t.totalSpan.inMicroseconds / 1000);
    }
  }

  static Map<String, dynamic> distribution(List<double> values) {
    if (values.isEmpty) return {'samples': 0, 'status': 'unmeasured'};
    final sorted = [...values]..sort();
    double q(double p) =>
        sorted[math.min(sorted.length - 1, (sorted.length * p).floor())];
    return {
      'samples': values.length,
      'p50Ms': q(.5),
      'p95Ms': q(.95),
      'p99Ms': q(.99),
      'maxMs': sorted.last,
      'over33_3Ms': values.where((x) => x > 33.3).length,
    };
  }

  // Polling must not repeatedly sort a growing history on the audio isolate.
  // Collect explicitly once at the end of a review window.
  Map<String, dynamic> snapshot() =>
      collected ??
      {
        'status': 'Collection deferred until the end of the trial',
        'samples': intervals.length,
      };
  void collect() => collected = {
    'windowSeconds': clock.elapsedMilliseconds / 1000,
    'frameIntervals': distribution(intervals),
    'flutterBuild': distribution(build),
    'flutterRaster': distribution(raster),
    'flutterTotalSpan': distribution(total),
    'injectedStalls': stalls,
    'deliberateStallIntervals': distribution(deliberateIntervals),
    'frameIntervalScope': 'UI intervals excluding explicitly injected stalls',
  };
}
