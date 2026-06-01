import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_controls.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('AutoExploreButton semantics', () {
    testWidgets('exposes tap action for assistive activation', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(semanticsHandle.dispose);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AutoExploreService?>.value(
            value: service,
            child: const Scaffold(
              body: AutoExploreButton(),
            ),
          ),
        ),
      );

      final data = _semanticsDataForLabel(tester, 'Start auto-explore');
      expect(data, isNotNull);
      expect(data!.hasAction(SemanticsAction.tap), isTrue);
      // ignore: deprecated_member_use
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    });
  });
}

SemanticsData? _semanticsDataForLabel(WidgetTester tester, String label) {
  // ignore: deprecated_member_use
  final root = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  SemanticsData? result;

  bool visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.label == label) {
      result = data;
      return false;
    }
    node.visitChildren(visit);
    return result == null;
  }

  if (root != null) visit(root);
  return result;
}
