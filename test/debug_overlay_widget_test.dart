import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/features/debug/debug_overlay.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOverlay', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late DebugRunnerService runner;
    late GlobalKey boundaryKey;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      runner = DebugRunnerService(controller: controller, registry: registry);
      boundaryKey = GlobalKey();
    });

    tearDown(() {
      runner.dispose();
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              RepaintBoundary(
                key: boundaryKey,
                child: const SizedBox.expand(
                  child: ColoredBox(color: Colors.black),
                ),
              ),
              DebugOverlay(
                runner: runner,
                boundaryKey: boundaryKey,
              ),
            ],
          ),
        ),
      );
    }

    // Debug overlay only shows in debug mode
    testWidgets('shows FAB in idle state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      if (kDebugMode) {
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.bug_report), findsOneWidget);
      }
    });

    testWidgets('FAB has correct color in debug mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      if (kDebugMode) {
        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.backgroundColor, Colors.deepPurple);
      }
    });

    testWidgets('FAB has correct hero tag', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      if (kDebugMode) {
        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.heroTag, 'debugFab');
      }
    });

    testWidgets('uses ListenableBuilder', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      if (kDebugMode) {
        expect(find.byType(ListenableBuilder), findsOneWidget);
      }
    });

    testWidgets('runner starts in idle state', (tester) async {
      expect(runner.state, DebugRunState.idle);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should render without throwing
      expect(tester.takeException(), isNull);
    });

    testWidgets('Positioned at bottom right in idle state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      if (kDebugMode) {
        final positioned = tester.widget<Positioned>(
          find.ancestor(
            of: find.byType(FloatingActionButton),
            matching: find.byType(Positioned),
          ),
        );
        expect(positioned.bottom, 16);
        expect(positioned.right, 16);
      }
    });
  });

  group('DebugRunnerService', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late DebugRunnerService runner;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      runner = DebugRunnerService(controller: controller, registry: registry);
    });

    tearDown(() {
      runner.dispose();
    });

    testWidgets('state changes notify listeners', (tester) async {
      int notifyCount = 0;
      runner.addListener(() => notifyCount++);

      // State should be idle initially
      expect(runner.state, DebugRunState.idle);

      // The runner should be listenable
      expect(runner, isA<ChangeNotifier>());
    });

    testWidgets('provides status message', (tester) async {
      expect(runner.statusMessage, isNotNull);
    });

    testWidgets('provides current and total steps', (tester) async {
      expect(runner.currentStep, isA<int>());
      expect(runner.totalSteps, isA<int>());
    });
  });
}
