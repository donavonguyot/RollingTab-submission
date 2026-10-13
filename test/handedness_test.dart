import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab/audio/transport.dart';
import 'package:rollingtab/model/music.dart';
import 'package:rollingtab/surface/guitar_surface.dart';
import 'package:rollingtab/surface/voicing_panel.dart';

class PausedGuitar extends GuitarState {
  @override
  final fixture = TabScore.fromJson(
    jsonDecode(File('assets/fixtures/guitar-voicings.json').readAsStringSync()),
  );
  @override
  double get time => 2.4;
  @override
  FeedbackMode get feedback => FeedbackMode.off;
  @override
  List<PerformedEvent> get events => [];
}

void main() {
  for (final size in [
    const Size(600, 240),
    const Size(342, 240),
    const Size(1464, 146),
  ]) {
    for (final depth in [0.0, .55, 1.0]) {
      test(
        'Handed perspective keeps time and strings ordered at $size / $depth',
        () {
          final state = PausedGuitar();
          final options = SurfaceOptions()..depth = depth;
          final high = TabNote(
            id: 'high',
            midi: 64,
            start: 0,
            duration: 1,
            stringNumber: 1,
          );
          final low = TabNote(
            id: 'low',
            midi: 40,
            start: 0,
            duration: 1,
            stringNumber: 6,
          );
          final right = GuitarProjection(state, options, size);
          options.leftHanded = true;
          final left = GuitarProjection(state, options, size);
          for (final projection in [right, left]) {
            var previousX = double.negativeInfinity;
            for (var step = 0; step <= 10; step++) {
              final at = state.time + step / 10 * options.lookAhead;
              final top = projection.point(high, at);
              final bottom = projection.point(low, at);
              // Future notes stay to the right and approach the left arrival line.
              expect(top.dx, greaterThan(previousX));
              expect(top.dy, lessThan(bottom.dy));
              expect(top.dx.isFinite && top.dy.isFinite, isTrue);
              expect(
                projection.markerRadius(at) * 2,
                lessThan(projection.stringSpacing(at)),
              );
              previousX = top.dx;
            }
          }
          double span(GuitarProjection p, double at) =>
              (p.point(low, at) - p.point(high, at)).distance;
          if (depth > 0) {
            // The nearer end is larger; handedness must swap that perspective.
            expect(
              span(right, state.time),
              greaterThan(span(right, state.time + options.lookAhead)),
            );
            expect(
              span(left, state.time),
              lessThan(span(left, state.time + options.lookAhead)),
            );
          } else {
            expect(left.point(high, state.time), right.point(high, state.time));
          }
          // A flat timeline has no viewpoint to reverse.
          options.effects = false;
          final flatLeft = GuitarProjection(
            state,
            options,
            size,
          ).point(high, state.time);
          options.leftHanded = false;
          expect(
            GuitarProjection(state, options, size).point(high, state.time),
            flatLeft,
          );
          options.dispose();
          state.dispose();
        },
      );
    }
  }
  for (final overlay in [false, true]) {
    testWidgets(
      'Left-handed ${overlay ? 'Overlay' : 'Now + next'} preserves note selection and timing',
      (tester) async {
        final state = PausedGuitar();
        final options = SurfaceOptions()..voicingOverlay = overlay;
        final timelineBefore = GuitarProjection(
          state,
          options,
          const Size(600, 240),
        ).point(state.fixture.notes.first, state.time);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoicingPanel(transport: state, options: options),
            ),
          ),
        );
        final boards = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is VoicingPainter,
        );
        var now = tester.getRect(boards.first);
        await tester.tapAt(Offset(now.left + 32, now.top + 126));
        expect(options.selection, {'em-low-e'});
        options.leftHanded = true;
        options.update();
        await tester.pump();
        expect(options.selection, {'em-low-e'});
        expect(state.time, 2.4);
        expect(
          GuitarProjection(
            state,
            options,
            const Size(600, 240),
          ).point(state.fixture.notes.first, state.time),
          isNot(timelineBefore),
        );
        expect(find.textContaining('LEFT-HANDED'), findsOneWidget);
        options.selection = {};
        now = tester.getRect(boards.first);
        await tester.tapAt(Offset(now.right - 32, now.top + 126));
        expect(options.selection, {'em-low-e'});
        final upcoming = tester.getRect(overlay ? boards.first : boards.last);
        await tester.tapAt(
          Offset(
            upcoming.right - 32 - (upcoming.width - 48) * 3 / 5,
            upcoming.top + 107,
          ),
        );
        expect(options.selection, {'c-bass'});
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        options.dispose();
        state.dispose();
      },
    );
  }
}
