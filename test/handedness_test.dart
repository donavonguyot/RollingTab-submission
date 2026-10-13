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
          timelineBefore,
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
