import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fractal Forge Integration Tests', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late TestLogger logger;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
      logger = TestLogger();
    });

    tearDown(() async {
      await logger.dispose();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          accessibilityService: accessibilityService,
          locale: const Locale('en'),
        ),
      );
      // Avoid indefinite pumpAndSettle: shader/animation frames may never fully settle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
    }

    Finder moduleCards() {
      // Catalog supports list + grid view. Keys differ by view mode.
      return find.byWidgetPredicate((w) {
        final k = w.key;
        if (k is! ValueKey) return false;
        final v = k.value;
        if (v is! String) return false;
        return v.startsWith('catalogModuleCard_') ||
            v.startsWith('catalogGridTile_');
      });
    }

    testWidgets('Catalog displays fractal modules', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      final moduleCount = moduleCards().evaluate().length;
      expect(moduleCount, greaterThanOrEqualTo(4));

      logger.logAction('test', 'Catalog shows $moduleCount modules');
      expect(logger.buffer.length, greaterThan(0));

      semantics.dispose();
    });

    testWidgets('Navigate to fractal viewer and back', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      // Tap the first module card
      await tester.tap(moduleCards().first);
      // Use pump with duration — shader animation never settles
      await tester.pump(const Duration(seconds: 2));

      // Should be on viewer screen with AppBar actions
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);

      logger.logNavigation('Navigated to viewer');

      // Go back to catalog (custom back button in app bar)
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      logger.logNavigation('Navigated back to catalog');
      expect(moduleCards().evaluate().length, greaterThanOrEqualTo(4));

      semantics.dispose();
    });

    testWidgets('Navigate to each fractal module viewer', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      final keys = moduleCards().evaluate().map((e) {
        final k = e.widget.key;
        if (k is! ValueKey) return null;
        final v = k.value;
        return v is String ? v : null;
      }).whereType<String>().toList();

      expect(keys.length, greaterThanOrEqualTo(4));

      // Smoke coverage: only sample a handful of modules to keep runtime reasonable
      // on emulators and in CI.
      final sampledKeys = keys.take(8).toList();

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
        await tester.pumpAndSettle();

        await tester.tap(cardFinder);
        await tester.pump(const Duration(seconds: 2));

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

      final searchField = find.byKey(const Key('catalogSearchField'));
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Julia');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(moduleCards().evaluate().length, greaterThanOrEqualTo(1));
      logger.logAction('test', 'Search filtered to Julia');

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(moduleCards().evaluate().length, greaterThanOrEqualTo(4));
      logger.logAction('test', 'Search cleared, modules visible');

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
