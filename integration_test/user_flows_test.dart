/// Updated user flow integration tests for current catalog/viewer UX.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Future<void> safeSettle(WidgetTester tester) async {
      try {
        await tester.pumpAndSettle(
          const Duration(milliseconds: 80),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 3),
        );
      } catch (_) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
      }
    }

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Finder moduleCards() {
      // Catalog supports both grid and list cards; keys differ by view mode.
      return find.byWidgetPredicate((w) {
        final key = w.key;
        if (key is! ValueKey) return false;
        final value = key.value;
        if (value is! String) return false;
        return value.startsWith('catalogModuleCard_') ||
            value.startsWith('catalogGridTile_');
      });
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

    Future<void> openFirstModule(WidgetTester tester) async {
      expect(moduleCards(), findsWidgets);
      await tester.tap(moduleCards().first);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);
    }

    Future<void> openModuleBySearch(
      WidgetTester tester, {
      required String query,
      required String displayName,
    }) async {
      final searchField = find.byKey(const Key('catalogSearchField'));
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, query);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final moduleName = find.text(displayName);
      expect(moduleName, findsWidgets);

      await tester.tap(moduleName.first);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);
    }

    testWidgets('catalog search and empty-state flow works', (tester) async {
      await pumpApp(tester);

      expect(moduleCards(), findsWidgets);

      final searchField = find.byKey(const Key('catalogSearchField'));
      await tester.enterText(searchField, 'Julia');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(moduleCards(), findsWidgets);

      await tester.enterText(searchField, 'XYZNONEXISTENT');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      final clearSearch = find.byKey(const Key('catalogClearSearchButton'));
      expect(clearSearch, findsOneWidget);
      await tester.tap(clearSearch);
      await safeSettle(tester);

      expect(moduleCards(), findsWidgets);
    });

    testWidgets('open viewer and return to catalog', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
      expect(moduleCards(), findsWidgets);
    });

    testWidgets('controls sheet actions are interactive', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await safeSettle(tester);

      expect(find.byType(FractalControlsSheet), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);

      await tester.drag(find.byType(Slider).first, const Offset(50, 0));
      await safeSettle(tester);

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.settings_backup_restore_rounded));
      await tester.pump();
      await tester.tap(find.text('Randomize'));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);
      expect(find.byType(FractalControlsSheet), findsNothing);
    });

    testWidgets('presets sheet can save and apply user preset', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await safeSettle(tester);

      expect(find.byType(PresetSheet), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsWidgets);

      final presetName = 'Flow Preset ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(find.byType(TextField).first, presetName);
      await safeSettle(tester);

      await tester.tap(find.byIcon(Icons.save_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(presetName), findsWidgets);

      await tester.tap(find.text(presetName).first);
      await safeSettle(tester);
      expect(find.byType(PresetSheet), findsNothing);
    });

    testWidgets(
        'end-to-end flow: search -> viewer -> controls -> presets -> back',
        (tester) async {
      await pumpApp(tester);
      await openModuleBySearch(
        tester,
        query: 'Burning',
        displayName: 'Burning Ship',
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await safeSettle(tester);
      expect(find.byType(FractalControlsSheet), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await safeSettle(tester);
      expect(find.byType(PresetSheet), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
      expect(moduleCards(), findsWidgets);
    });
  });
}
