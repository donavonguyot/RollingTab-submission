import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab_audio/rollingtab_audio.dart';

class ClockSink implements PcmSink {
  RenderPcm? render;
  int submitted = 0, starts = 0;
  double played = 0;
  @override
  void unlock() {}
  @override
  Future<void> start(RenderPcm r) async {
    starts++;
    render = r;
    submitted = 0;
    played = 0;
    pump(5);
  }

  void pump(int blocks) {
    for (var i = 0; i < blocks; i++) {
      render!(Float32List(512), Float32List(512), submitted);
      submitted += 512;
    }
  }

  @override
  Future<void> stop() async {
    render = null;
    submitted = 0;
    played = 0;
  }

  @override
  Future<void> dispose() => stop();
  @override
  double get playedFrames => played;
  @override
  Map<String, dynamic> get diagnostics => {};
}

void main() {
  final data = ByteData.sublistView(
    File('assets/soundfont/GeneralUser_GS.sf2').readAsBytesSync(),
  );
  final passage = Passage(
    start: 0,
    end: 12,
    program: 24,
    notes: [
      const AudioNote(id: 'held', midi: 64, channel: 1, start: 0, end: 12),
    ],
  );
  test('Speed takes effect only after already queued frames', () async {
    final sink = ClockSink(), engine = ContinuousEngine(sink: ClockSink());
    await engine.dispose();
    final e = ContinuousEngine(sink: sink);
    await e.initialize(data, passage, 0, 1, true, (_) {});
    await e.play();
    e.speed(.25);
    sink.played = 1024;
    expect(e.position, closeTo(1024 / 44100, 1e-9));
    sink.pump(1);
    sink.played = 2816;
    expect(e.position, closeTo((2560 + 256 * .25) / 44100, 1e-9));
    expect(sink.starts, 1);
    expect(e.core!.attacks, 1);
    expect(e.diagnostics['lastSpeedDelayMs'], lessThan(100));
    await e.dispose();
  });
  test('Cancelled reconstruction cannot install a stale score', () async {
    final sink = ClockSink(), e = ContinuousEngine(sink: ClockSink());
    await e.dispose();
    final engine = ContinuousEngine(sink: sink);
    final first = engine.initialize(data, passage, 10, 1, true, (_) {});
    engine.cancel();
    await engine.initialize(data, passage, 1, .73, false, (_) {});
    await first;
    expect(engine.position, 1);
    expect(engine.core!.speed, .73);
    expect(engine.running, false);
    await engine.play();
    await engine.seek(3, resume: true);
    expect(engine.position, 3);
    expect(engine.running, true);
    await engine.pause();
    expect(engine.running, false);
    await engine.dispose();
  });
}
