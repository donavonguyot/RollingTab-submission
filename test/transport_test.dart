import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab/audio/transport.dart';
import 'package:rollingtab/audio/output.dart';
import 'package:rollingtab/model/music.dart';

class FakeAudio implements AudioPort {
  double clock = 0, rate = 1;
  int loaded = 0;
  bool running = false;
  Completer<void>? pending;
  @override
  Future<void> initialize(
    TabScore s,
    double a,
    double b,
    double t,
    double speed,
    bool loop,
    FeedbackMode f,
    void Function(double) progress,
  ) async {
    loaded++;
    clock = t;
    rate = speed;
    await pending?.future;
  }

  @override
  void unlock() {}
  @override
  Future<void> play() async {
    running = true;
  }

  @override
  Future<void> pause() async {
    running = false;
  }

  @override
  Future<void> seek(double value, {required bool resume}) async {
    clock = value;
    running = resume;
  }

  @override
  void loop(bool enabled) {}
  @override
  void speed(double value) {
    rate = value;
  }

  @override
  void cancel() {
    running = false;
  }

  @override
  double get position => clock;
  @override
  bool get alive => running;
  @override
  int get voices => running ? 1 : 0;
  @override
  int get wraps => 0;
  @override
  Map<String, dynamic> get diagnostics => {};
  @override
  Future<void> dispose() async {}
}

TabScore fixture() => const TabScore(
  id: 'test',
  title: 'test',
  notes: [],
  duration: 12,
  guitar: true,
);
void main() {
  test(
    'Seek during initialization preserves play intent and clears busy',
    () async {
      final a = FakeAudio()..pending = Completer<void>();
      final t = TabTransport(fixture(), a);
      final first = t.prepare(resume: true);
      final seek = t.seek(3);
      a.pending!.complete();
      await Future.wait([first, seek]);
      expect(t.time, 3);
      expect(t.ready, true);
      expect(t.busy, false);
      expect(t.playing, true);
      t.dispose();
    },
  );

  test('Live speed retains position and does not initialize again', () async {
    final a = FakeAudio(), t = TabTransport(fixture(), FakeAudio());
    t.dispose();
    final s = TabTransport(fixture(), a);
    await s.toggle();
    a.clock = 3.2;
    s.tick();
    for (final v in [.25, .73, 1.0, 1.5]) {
      await s.setTempo(v);
      expect(s.playing, true);
      expect(s.time, 3.2);
      expect(a.rate, v);
    }
    expect(a.loaded, 1);
    s.pause();
    await s.seek(4.5);
    expect(s.playing, false);
    expect(a.position, 4.5);
    s.dispose();
  });
  test('Loop wrap and recovery derive from audio position', () async {
    final a = FakeAudio(), t = TabTransport(fixture(), FakeAudio());
    t.dispose();
    final s = TabTransport(fixture(), a);
    await s.toggle();
    a.clock = 11.9;
    s.tick();
    a.clock = .2;
    s.tick();
    expect(s.wraps, 1);
    a.clock = 7.25;
    s.tick();
    expect(s.time, 7.25);
    s.dispose();
  });
  test('Invalid bounds and speeds rejected', () async {
    final t = TabTransport(fixture(), FakeAudio());
    await expectLater(t.setPassage(5, 4), throwsArgumentError);
    await expectLater(t.setPassage(0, 13), throwsArgumentError);
    for (final v in [double.nan, double.infinity, .249, 1.51, .735]) {
      await expectLater(t.setTempo(v), throwsArgumentError);
    }
    t.dispose();
  });
  test('Cancelled initialization cannot resume or set ready', () async {
    final a = FakeAudio()..pending = Completer<void>();
    final t = TabTransport(fixture(), a);
    final pending = t.prepare(resume: true);
    t.cancel();
    a.pending!.complete();
    await pending;
    expect(t.ready, false);
    expect(t.playing, false);
    expect(a.running, false);
    t.dispose();
  });
  test('Connected scores reject simulated feedback', () async {
    final t = TabTransport(
      TabScore.fromJson({
        ...fixture().toJson(),
        'provenance': {'connected': true},
      }),
      FakeAudio(),
    );
    await expectLater(t.setFeedback(FeedbackMode.imperfect), throwsStateError);
    t.dispose();
  });
}
