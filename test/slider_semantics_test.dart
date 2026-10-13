import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rollingtab/widgets/slider_overlay.dart';

// Inspect the actual incremental serialization sent to the desktop bridge,
// rather than only the framework's logical semantics tree.
class RecordingBinding extends AutomatedTestWidgetsFlutterBinding {
  final children = <int, List<int>>{};
  final orphans = <int>[];
  @override
  ui.SemanticsUpdateBuilder createSemanticsUpdateBuilder() =>
      RecordingBuilder(this);
}

class RecordingBuilder implements ui.SemanticsUpdateBuilder {
  RecordingBuilder(this.binding);
  final RecordingBinding binding;
  final delegate = ui.SemanticsUpdateBuilder();
  final updated = <int>[];
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #updateNode) {
      final args = invocation.namedArguments;
      final id = args[#id] as int;
      binding.children[id] = List<int>.from(
        args[#childrenInTraversalOrder] as Iterable,
      );
      updated.add(id);
      return Function.apply(delegate.updateNode, [], args);
    }
    if (invocation.memberName == #updateCustomAction) {
      return Function.apply(
        delegate.updateCustomAction,
        [],
        invocation.namedArguments,
      );
    }
    return super.noSuchMethod(invocation);
  }

  @override
  ui.SemanticsUpdate build() {
    final reachable = <int>{};
    void visit(int id) {
      if (!reachable.add(id)) return;
      for (final child in binding.children[id] ?? <int>[]) {
        visit(child);
      }
    }

    visit(0);
    binding.orphans.addAll(updated.where((id) => !reachable.contains(id)));
    return delegate.build();
  }
}

void main() {
  final binding = RecordingBinding();
  testWidgets(
    'Slider stays connected to serialized semantics through dialog and drag',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: StatefulBuilder(
                      builder: (context, update) => sliderWithLocalOverlay(
                        Slider(value: .5, onChanged: (_) => update(() {})),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(60, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(binding.orphans, isEmpty);
      semantics.dispose();
    },
  );
}
