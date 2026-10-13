import 'package:flutter/foundation.dart';

import '../model/music.dart';
import 'output.dart';

/// Read-only contract consumed by reusable guitar widgets.
abstract class GuitarState extends ChangeNotifier {
  TabScore get fixture;
  double get time;
  FeedbackMode get feedback;
  List<PerformedEvent> get events;
}

class TabTransport extends GuitarState {
  final AudioPort audio;
  @override
  TabScore fixture;
  @override
  double time = 0;
  @override
  FeedbackMode feedback = FeedbackMode.off;
  @override
  List<PerformedEvent> events = [];
  double start = 0, end, tempo = 1, progress = 0;
  bool playing = false, looping = true, ready = false, busy = false;
  String? error;
  int epoch = 0, wraps = 0;
  bool _seekResume = false;
  TabTransport(this.fixture, this.audio) : end = fixture.duration.clamp(0, 60);
  void _invalidate() {
    epoch++;
    audio.cancel();
    playing = false;
    _seekResume = false;
    busy = false;
    ready = false;
  }

  Future<void> setFixture(
    TabScore score, {
    double? passageStart,
    double? passageEnd,
  }) async {
    _invalidate();
    fixture = score;
    feedback = FeedbackMode.off;
    events = [];
    start = (passageStart ?? 0).clamp(
      0,
      (score.duration - .1).clamp(0, double.infinity),
    );
    end = (passageEnd ?? start + 30).clamp(
      start + .1,
      (start + 60).clamp(0, score.duration),
    );
    time = start;
    error = null;
    notifyListeners();
  }

  Future<void> setPassage(double a, double b) async {
    if (!a.isFinite ||
        !b.isFinite ||
        a < 0 ||
        b <= a ||
        b - a > 60.0001 ||
        b > fixture.duration + .0001) {
      throw ArgumentError('Choose 0–60 seconds within this score.');
    }
    _invalidate();
    start = a;
    end = b;
    time = a;
    error = null;
    notifyListeners();
  }

  Future<void> prepare({bool resume = false}) async {
    final token = ++epoch;
    busy = true;
    _seekResume = resume;
    playing = false;
    ready = false;
    error = null;
    progress = 0;
    notifyListeners();
    try {
      await audio.initialize(
        fixture,
        start,
        end,
        time,
        tempo,
        looping,
        feedback,
        (v) {
          if (token == epoch) {
            progress = v;
            notifyListeners();
          }
        },
      );
      if (token != epoch) return;
      audio.speed(tempo);
      audio.loop(looping);
      _seekResume = false;
      ready = true;
      busy = false;
      progress = 1;
      if (resume) {
        await audio.play();
        if (token != epoch) return;
        playing = true;
      }
    } catch (e) {
      if (token == epoch) {
        error = '$e';
        ready = false;
        busy = false;
        playing = false;
      }
    }
    if (token == epoch) notifyListeners();
  }

  void cancel() {
    _invalidate();
    error = null;
    notifyListeners();
  }

  Future<void> toggle() async {
    audio.unlock();
    if (busy) {
      cancel();
      return;
    }
    if (playing) {
      await pause();
      return;
    }
    if (time >= end - .001) time = start;
    if (!ready) {
      await prepare(resume: true);
      return;
    }
    final token = ++epoch;
    busy = true;
    notifyListeners();
    try {
      await audio.seek(time, resume: false);
      if (token != epoch) return;
      await audio.play();
      if (token != epoch) return;
      busy = false;
      playing = true;
    } catch (e) {
      if (token == epoch) {
        busy = false;
        playing = false;
        error = '$e';
      }
    }
    if (token == epoch) notifyListeners();
  }

  Future<void> pause() async {
    if (playing) tick();
    final token = ++epoch;
    playing = false;
    _seekResume = false;
    busy = true;
    notifyListeners();
    try {
      await audio.pause();
    } catch (e) {
      if (token == epoch) error = '$e';
    }
    if (token == epoch) {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> seek(double value) async {
    final resume = playing || (busy && _seekResume);
    _seekResume = resume;
    final token = ++epoch;
    time = value.clamp(start, end);
    if (!ready) {
      if (busy) {
        await prepare(resume: resume);
      } else {
        notifyListeners();
      }
      return;
    }
    busy = true;
    playing = false;
    notifyListeners();
    try {
      await audio.seek(time, resume: resume);
      if (token != epoch) return;
      busy = false;
      _seekResume = false;
      playing = resume;
    } catch (e) {
      if (token == epoch) {
        busy = false;
        playing = false;
        error = '$e';
      }
    }
    if (token == epoch) notifyListeners();
  }

  Future<void> setTempo(double value) async {
    tempo = canonicalSpeed(value);
    audio.speed(tempo);
    notifyListeners();
  }

  Future<void> setFeedback(FeedbackMode mode) async {
    if (fixture.provenance['connected'] == true && mode != FeedbackMode.off) {
      throw StateError('Simulation is only available in authored studies');
    }
    if (playing) tick();
    final resume = playing;
    _invalidate();
    feedback = mode;
    events = performedEvents(fixture, mode);
    notifyListeners();
    await prepare(resume: resume);
  }

  void setLoop(bool value) {
    looping = value;
    if (ready) audio.loop(value);
    notifyListeners();
  }

  void tick() {
    if (!playing || busy || !ready) return;
    final outputError = audio.diagnostics['error'];
    if (outputError != null) {
      error = 'Audio output failed: $outputError';
      time = audio.position.clamp(start, end);
      audio.cancel();
      playing = false;
      ready = false;
      notifyListeners();
      return;
    }
    if (!audio.alive) {
      playing = false;
      time = end;
      audio.pause();
    } else {
      final next = audio.position.clamp(start, end);
      if (next < time - .05 && looping) wraps++;
      time = next;
    }
    notifyListeners();
  }

  Map<String, dynamic> snapshot() => {
    'scoreTime': time,
    'start': start,
    'end': end,
    'audioPosition': ready ? audio.position : null,
    'tempo': tempo,
    'playing': playing,
    'ready': ready,
    'busy': busy,
    'progress': progress,
    'error': error,
    'epoch': epoch,
    'wraps': wraps,
    'voices': audio.voices,
    'fixture': fixture.id,
    'feedback': feedback.name,
    'audio': audio.diagnostics,
  };
  @override
  void dispose() {
    epoch++;
    audio.dispose();
    super.dispose();
  }
}
