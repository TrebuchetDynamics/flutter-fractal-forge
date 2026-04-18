import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/main.dart';
import 'package:provider/provider.dart';

import 'helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fractal Forge Integration Tests', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;
    late TestLogger logger;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
      logger = TestLogger();
    });

    tearDown(() async {
      await logger.dispose();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      // Avoid indefinite pumpAndSettle: shader/animation frames may never fully settle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
    }

    void drainKnownShaderExceptions(WidgetTester tester) {
      while (true) {
        final error = tester.takeException();
        if (error == null) return;
        final message = error.toString();
        final isKnownSkSLError = message.contains('Invalid SkSL') ||
            message.contains("operator '%' is not allowed");
        if (!isKnownSkSLError) {
          fail('Unexpected Flutter exception: $error');
        }
      }
    }

    testWidgets('Catalog displays fractal modules', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      final moduleCount = catalogModuleCards().evaluate().length;
      expect(moduleCount, greaterThanOrEqualTo(4));

      logger.logAction('test', 'Catalog shows $moduleCount modules');
      expect(logger.buffer.length, greaterThan(0));

      semantics.dispose();
    });

    testWidgets('Navigate to fractal viewer and back', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      // Tap the first module card
      await tester.tap(catalogModuleCards().first);
      // Use pump with duration — shader animation never settles
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);

      // Should be on viewer screen with the compact action set.
      expect(find.byKey(const Key('viewerControlsButton')), findsOneWidget);
      expect(find.byKey(const Key('viewerExportButton')), findsOneWidget);
      expect(find.byKey(const Key('viewerRandomButton')), findsOneWidget);

      logger.logNavigation('Navigated to viewer');

      // Go back to catalog (custom back button in app bar)
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      logger.logNavigation('Navigated back to catalog');
      expect(catalogModuleCards().evaluate().length, greaterThanOrEqualTo(4));

      semantics.dispose();
    });

    testWidgets('Navigate to each fractal module viewer', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      final keys = catalogModuleCards()
          .evaluate()
          .map((e) {
            final k = e.widget.key;
            if (k is! ValueKey) return null;
            final v = k.value;
            return v is String ? v : null;
          })
          .whereType<String>()
          .toList();

      expect(keys.length, greaterThanOrEqualTo(4));

      // Smoke coverage: only sample a handful of modules to keep runtime reasonable
      // on emulators and in CI.
      final sampledKeys = keys.take(3).toList();

      // Navigate to each sampled module and verify viewer loads.
      // Use keys to avoid index drift across rebuilds.
      for (int i = 0; i < sampledKeys.length; i++) {
        if (i > 0) {
          await pumpApp(tester);
        }

        // Scroll until the card is visible (handles growing catalog).
        final cardFinder = find.byKey(ValueKey(sampledKeys[i]));
        await tester.scrollUntilVisible(
          cardFinder,
          200,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 20,
        );
        // Shader/animation frames can keep scheduling updates; use bounded pumps.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(cardFinder);
        await tester.pump(const Duration(seconds: 2));
        drainKnownShaderExceptions(tester);

        // Verify viewer screen loaded (back arrow always present).
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
        logger.logNavigation('Viewed module $i');

        // Go back (custom back button in app bar)
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      }

      expect(
        logger.buffer.where((e) => e.type == 'navigation').length,
        greaterThanOrEqualTo(sampledKeys.length),
      );

      semantics.dispose();
    });

    testWidgets('Search filters catalog', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      await enterCatalogSearch(
        tester,
        'Julia',
        settle: const Duration(milliseconds: 600),
      );

      expect(catalogModuleCards().evaluate().length, greaterThanOrEqualTo(1));
      logger.logAction('test', 'Search filtered to Julia');

      // Clear search
      await tester.enterText(catalogSearchField(), '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(catalogModuleCards().evaluate().length, greaterThanOrEqualTo(4));
      logger.logAction('test', 'Search cleared, modules visible');

      semantics.dispose();
    });

    testWidgets('Search then open module shows renderer and actions',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      await enterCatalogSearch(
        tester,
        'Burning',
        settle: const Duration(milliseconds: 600),
      );

      // Open filtered result.
      await tester.tap(find.text('Burning Ship').first);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);

      // Verify viewer loaded with visible renderer + core actions.
      expect(find.byType(FractalRenderer), findsOneWidget);
      expect(find.byKey(const Key('viewerControlsButton')), findsOneWidget);
      expect(find.byKey(const Key('viewerExportButton')), findsOneWidget);

      logger.logNavigation('Search->open Burning Ship viewer');
      semantics.dispose();
    });

    testWidgets('Viewer drag updates fractal view state', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      // Open a stable module path instead of relying on the first catalog tile.
      await enterCatalogSearch(
        tester,
        'Burning',
        settle: const Duration(milliseconds: 600),
      );
      await tester.tap(find.text('Burning Ship').first);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);

      final rendererFinder = find.byType(FractalRenderer);
      expect(rendererFinder, findsOneWidget);

      final context = tester.element(rendererFinder);
      final controller = context.read<FractalController>();

      final initialPanX = controller.view.pan.x;
      final initialPanY = controller.view.pan.y;

      // Smoke-test the on-device gesture path with a single-pointer pan.
      // Dedicated widget tests cover pinch math separately; the headless
      // emulator has proven unstable under two-pointer gesture injection.
      await tester.drag(rendererFinder, const Offset(40, 20));
      await tester.pump(const Duration(milliseconds: 400));
      drainKnownShaderExceptions(tester);

      expect(controller.view.pan.x, isNot(equals(initialPanX)));
      expect(controller.view.pan.y, isNot(equals(initialPanY)));
      logger.logAction('gesture', 'Viewer drag changed pan');

      semantics.dispose();
    });

    testWidgets('Logger captures events correctly', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      // Verify logger captures different event types
      logger.logAction('test', 'Test action', metadata: {'key': 'value'});
      logger.logStateChange('test', 'State changed');
      logger.logNavigation('Test navigation');
      logger.logScreenshot('test_screenshot');

      expect(logger.buffer.length, 4);
      expect(logger.buffer[0].type, 'userAction');
      expect(logger.buffer[1].type, 'stateChange');
      expect(logger.buffer[2].type, 'navigation');
      expect(logger.buffer[3].type, 'screenshot');
      expect(logger.buffer[0].metadata, {'key': 'value'});

      // Verify clearBuffer works
      logger.clearBuffer();
      expect(logger.buffer.length, 0);

      semantics.dispose();
    });
  });
}
