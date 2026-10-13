import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab/widgets/speed_control.dart';

void main() {
  testWidgets(
    'Editable speed rejects fractional or out-of-range input and resets',
    (tester) async {
      double speed = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SpeedControl(
                speed: speed,
                onChanged: (v) => setState(() => speed = v),
              ),
            ),
          ),
        ),
      );
      final field = find.byType(TextField);
      await tester.enterText(field, '73');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(speed, .73);
      await tester.enterText(field, '73.5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(speed, .73);
      expect(find.text('Enter 25–150'), findsOneWidget);
      await tester.tap(find.byTooltip('Reset speed to 100%'));
      await tester.pump();
      expect(speed, 1);
    },
  );
}
