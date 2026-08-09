/// Updated user flow integration tests for current catalog/viewer UX.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
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
      expect(catalogModuleCards(), findsWidgets);
      await tester.tap(catalogModuleCards().first);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);
    }

    Future<void> openModuleBySearch(
      WidgetTester tester, {
      required String query,
      required String displayName,
      required String catalogId,
    }) async {
      await enterCatalogSearch(tester, query);

      final moduleName = find.text(displayName);
      expect(moduleName, findsWidgets);
      final moduleCard = catalogModuleCard(catalogId);
      expect(moduleCard, findsOneWidget);
      await tester.ensureVisible(moduleCard);
      await safeSettle(tester);
      await tester.tap(moduleCard);
      await tester.pump(const Duration(seconds: 2));
      drainKnownShaderExceptions(tester);
    }

    testWidgets('catalog search and empty-state flow works', (tester) async {
      await pumpApp(tester);

      expect(catalogModuleCards(), findsWidgets);

      await enterCatalogSearch(tester, 'Julia');
      expect(catalogModuleCards(), findsWidgets);

      await tester.enterText(catalogSearchField(), 'XYZNONEXISTENT');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      final clearSearch = find.byKey(const Key('catalogClearSearchButton'));
      expect(clearSearch, findsOneWidget);
      await tester.tap(clearSearch);
      await safeSettle(tester);

      expect(catalogModuleCards(), findsWidgets);
    });

    testWidgets('open viewer and return to catalog', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      expect(find.byKey(const Key('viewerRandomParamsButton')), findsOneWidget);
      expect(find.byKey(const Key('viewerExportButton')), findsOneWidget);

      Navigator.of(tester.element(find.byType(FractalRenderer))).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(catalogModuleCards(), findsWidgets);
    });

    testWidgets('controls sheet actions are interactive', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      await tester.tap(find.byKey(const Key('viewerRandomParamsButton')));
      await safeSettle(tester);

      expect(find.byType(FractalControlsHud), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);

      await tester.drag(find.byType(Slider).first, const Offset(50, 0));
      await safeSettle(tester);

      final resetView = find.byIcon(Icons.home_filled);
      await tester.ensureVisible(resetView);
      await safeSettle(tester);
      await tester.tap(resetView);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.settings_backup_restore_rounded));
      await tester.pump();
      await tester.tap(find.text('Randomize'));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);
      expect(find.byType(FractalControlsHud), findsNothing);
    });

    testWidgets('presets sheet can save and apply user preset', (tester) async {
      await pumpApp(tester);
      await openFirstModule(tester);

      await openViewerPresets(tester);
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

      final savedPresetChip = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('userPresetChip_');
      });
      expect(savedPresetChip, findsOneWidget);
      await tester.ensureVisible(savedPresetChip);
      await safeSettle(tester);
      await tester.tap(savedPresetChip);
      await safeSettle(tester);
      expect(find.byType(PresetSheet), findsNothing);
    });

    testWidgets(
        'end-to-end flow: search -> viewer -> controls -> presets -> back',
        (tester) async {
      await pumpApp(tester);
      await openModuleBySearch(
        tester,
        query: 'Burning Ship',
        displayName: 'Burning Ship',
        catalogId: 'core.burning_ship',
      );

      await tester.tap(find.byKey(const Key('viewerRandomParamsButton')));
      await safeSettle(tester);
      expect(find.byType(FractalControlsHud), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);

      await openViewerPresets(tester);
      await safeSettle(tester);
      expect(find.byType(PresetSheet), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await safeSettle(tester);

      Navigator.of(tester.element(find.byType(FractalRenderer))).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(catalogModuleCards(), findsWidgets);
    });
  });
}
