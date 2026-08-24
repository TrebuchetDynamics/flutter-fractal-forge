import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_controls.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
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

      expect(
        find.text('Auto-pilot paused while you adjust the view.'),
        findsOneWidget,
      );
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Play'), findsNothing);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('uses the shared scrollable sheet at 3x phone text scale',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);
      service.start();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(3),
            ),
            child: child!,
          ),
          home: ChangeNotifierProvider<AutoExploreService>.value(
            value: service,
            child: const Scaffold(body: AutoExploreSettingsSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Stop')).dy,
          greaterThan(tester.getTopLeft(find.text('Pause')).dy));
      expect(tester.takeException(), isNull);

      service.stop();
      await tester.pump();
    });
  });

  group('AutoExploreButton semantics', () {
    testWidgets('matches the viewer FAB size and circular treatment',
        (tester) async {
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AutoExploreService?>.value(
            value: service,
            child: const Scaffold(body: AutoExploreButton()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          tester.getSize(find.byType(AutoExploreButton)), const Size(48, 48));
      final surface = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AutoExploreButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
          ),
        ),
      );
      expect(surface.constraints?.maxWidth, 44);
      expect(surface.constraints?.maxHeight, 44);
      expect((surface.decoration! as BoxDecoration).shape, BoxShape.circle);
    });

    testWidgets('exposes primary and secondary assistive actions',
        (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      var settingsOpened = false;
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AutoExploreService?>.value(
            value: service,
            child: Scaffold(
              body: AutoExploreButton(
                onLongPress: () => settingsOpened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final matches = _semanticsDataForLabel(tester, 'Start auto-explore');
      expect(matches, hasLength(1));
      final data = matches.single;
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.hasAction(SemanticsAction.longPress), isTrue);
      expect(
        data.hint,
        'Long press or Shift+Enter opens the secondary action.',
      );
      // ignore: deprecated_member_use
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);

      await tester.longPress(find.byType(AutoExploreButton));
      expect(settingsOpened, isTrue);

      semanticsHandle.dispose();
    });

    testWidgets('labels user-correction yield without claiming active motion',
        (tester) async {
      final semanticsHandle = tester.ensureSemantics();
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
      await tester.pumpAndSettle();

      final yieldedData = _semanticsDataForLabel(tester, 'Auto-pilot paused');
      final activeData = _semanticsDataForLabel(tester, 'Pause auto-explore');

      expect(yieldedData, hasLength(1));
      expect(yieldedData.single.hasAction(SemanticsAction.tap), isTrue);
      expect(activeData, isEmpty);

      semanticsHandle.dispose();
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
      await tester.pumpAndSettle();

      expect(service.pausedByUserCorrection, isTrue);
      expect(service.isPaused, isFalse);

      await tester.tap(find.byType(AutoExploreButton));
      await tester.pump();

      expect(service.isExploring, isTrue);
      expect(service.isPaused, isFalse);
      expect(service.pausedByUserCorrection, isFalse);

      service.stop();
      await tester.pump();
    });

    testWidgets('activates via keyboard Enter when focused', (tester) async {
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
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
      await tester.pumpAndSettle();

      expect(service.isExploring, isFalse);

      Focus.of(
        tester.element(
          find.descendant(
            of: find.byType(AutoExploreButton),
            matching: find.byType(GestureDetector),
          ),
        ),
      ).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(service.isExploring, isTrue);

      service.stop();
      await tester.pump();
    });
  });
}

List<SemanticsData> _semanticsDataForLabel(
  WidgetTester tester,
  String label,
) {
  // ignore: deprecated_member_use
  final root = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  final result = <SemanticsData>[];

  bool visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.label == label) {
      result.add(data);
    }
    node.visitChildren(visit);
    return true;
  }

  if (root != null) visit(root);
  return result;
}
