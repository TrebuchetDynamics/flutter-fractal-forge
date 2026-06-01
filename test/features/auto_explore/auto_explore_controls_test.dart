import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_controls.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('AutoExploreSettingsSheet', () {
    testWidgets('shows resume affordance while auto-explore is yielded',
        (tester) async {
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      service.onUserInteractionStart();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AutoExploreService>.value(
            value: service,
            child: const Scaffold(
              body: AutoExploreSettingsSheet(),
            ),
          ),
        ),
      );

      expect(find.text('Auto-pilot paused (user correction)'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
    });
  });

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

    testWidgets('labels user-correction yield without claiming active motion',
        (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(semanticsHandle.dispose);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      service.onUserInteractionStart();

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

      final yieldedData = _semanticsDataForLabel(tester, 'Auto-pilot paused');
      final activeData = _semanticsDataForLabel(tester, 'Pause auto-explore');

      expect(yieldedData, isNotNull);
      expect(yieldedData!.hasAction(SemanticsAction.tap), isTrue);
      expect(activeData, isNull);
    });

    testWidgets('tap resumes from user-correction yield instead of pausing',
        (tester) async {
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      service.onUserInteractionStart();

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

      expect(service.pausedByUserCorrection, isTrue);
      expect(service.isPaused, isFalse);

      await tester.tap(find.byType(AutoExploreButton));
      await tester.pump();

      expect(service.isExploring, isTrue);
      expect(service.isPaused, isFalse);
      expect(service.pausedByUserCorrection, isFalse);
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
