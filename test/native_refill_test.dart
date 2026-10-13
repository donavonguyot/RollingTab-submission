import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:rollingtab_audio/src/sink_native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Native refill notifications are retained while submissions await acknowledgement', () async {
    final acknowledgements = <Completer<void>>[];
    const channel = MethodChannel('flutter_pcm_sound/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'feed') {
            final c = Completer<void>();
            acknowledgements.add(c);
            await c.future;
          }
          return null;
        });
    final sink = NativePcmSink();
    var rendered = 0;
    await sink.start((l, r, frame) {
      rendered++;
    });
    await Future<void>.delayed(Duration.zero);
    expect(rendered, 5);
    final callback = FlutterPcmSound.onFeedSamplesCallback!;
    callback(2048);
    await Future<void>.delayed(Duration.zero);
    expect(
      rendered,
      6,
      reason: 'A new low-water event must not be discarded while feed futures are pending',
    );
    final stopped = sink.stop();
    callback(0);
    expect(rendered, 6, reason: 'Stale callbacks must not render after stop');
    for (final c in acknowledgements) {
      c.complete();
    }
    await stopped;
    expect(sink.diagnostics['pendingSubmissions'], 0);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
