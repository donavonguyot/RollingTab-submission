import 'dart:typed_data';

typedef RenderPcm = void Function(
  Float32List left,
  Float32List right,
  int firstFrame,
);

abstract class PcmSink {
  void unlock();
  Future<void> start(RenderPcm render);
  Future<void> stop();
  Future<void> dispose();
  double get playedFrames;
  Map<String, dynamic> get diagnostics;
}
