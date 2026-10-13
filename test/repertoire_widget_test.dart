import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rollingtab/main.dart';
import 'package:rollingtab/backend/connection.dart';
import 'package:rollingtab/model/music.dart';

import 'independent_connection_test.dart' show metadata;

void main() {
  testWidgets(
    'Repertoire dialog opens under the navigator and lists catalog metadata',
    (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final b = BackendConnection(
        client: MockClient(
          (r) async => http.Response(
            jsonEncode(
              r.url.path.endsWith('/list')
                  ? [metadata().toJson()]
                  : metadata().toJson(),
            ),
            200,
          ),
        ),
        bytesClient: MockClient(
          (_) async => http.Response.bytes(
            File('rollingtab_server/assets/scores/paganini-guitar.pdmx.json.gz')
                .readAsBytesSync(),
            200,
          ),
        ),
      );
      final study = TabScore.fromJson(
        jsonDecode(
          File('assets/fixtures/guitar-voicings.json').readAsStringSync(),
        ),
      );
      await tester.pumpWidget(RollingTabApp(studies: [study], connection: b));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byTooltip('Choose server repertoire'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Server repertoire'), findsOneWidget);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      expect(find.text('Paganini'), findsOneWidget);
      await tester.tap(find.text('Paganini'));
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Server repertoire'), findsNothing);
      for (final size in [
        const Size(1440, 900),
        const Size(1024, 768),
        const Size(390, 844),
      ]) {
        tester.view.physicalSize = size;
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'Layout $size');
      }
      tester.view.physicalSize = const Size(1440, 900);
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '73');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.byTooltip('Choose server repertoire'));
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Paganini'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Discard unsaved passage edits?'), findsOneWidget);
      await tester.tap(find.text('Keep practicing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Discard unsaved passage edits?'), findsNothing);
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );
}
