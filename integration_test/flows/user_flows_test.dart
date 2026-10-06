/// Updated user flow integration tests for current catalog/viewer UX.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      // Device accessibility can attach its platform semantics client after a
      // test starts, which looks like a leaked tester-owned handle. These flows
      // do not exercise screen-reader integration; dedicated accessibility
      // tests opt into semantics explicitly.
      binding.platformDispatcher.semanticsEnabledTestValue = false;
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

    Future<void> openMandelbrotModule(WidgetTester tester) async {
      await enterCatalogSearch(tester, 'Mandelbrot');
      final moduleCard = catalogModuleCard('core.mandelbrot');
      expect(moduleCard, findsOneWidget);
      await tester.tap(moduleCard);
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
      await openMandelbrotModule(tester);

      expect(find.byKey(const Key('viewerRandomParamsButton')), findsOneWidget);
      expect(find.byKey(const Key('viewerExportButton')), findsOneWidget);

      Navigator.of(tester.element(find.byType(FractalRenderer))).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(catalogModuleCards(), findsWidgets);
    });

    testWidgets('controls sheet actions are interactive', (tester) async {
      await pumpApp(tester);
      await openMandelbrotModule(tester);

      await tester.longPress(
        find.byKey(const Key('viewerRandomParamsButton')),
      );
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
      await openMandelbrotModule(tester);

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

      await tester.longPress(
        find.byKey(const Key('viewerRandomParamsButton')),
      );
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

    // Run this case with --dart-define=FORCE_GPU_RENDER=true to exercise the
    // actual first viewer frame instead of the automated-test placeholder.
    testWidgets(
      'Julia viewer starts from its configured seed and view',
      (tester) async {
        await pumpApp(tester);
        await openModuleBySearch(
          tester,
          query: 'Julia',
          displayName: 'Julia',
          catalogId: 'core.julia',
        );

        final renderer = find.byType(FractalRenderer);
        expect(renderer, findsOneWidget);
        final controller = Provider.of<FractalController>(
          tester.element(renderer),
          listen: false,
        );
        expect(controller.module.id, 'julia');
        expect(controller.params['juliaCReal'], -0.8);
        expect(controller.params['juliaCImag'], 0.156);
        expect(controller.view.pan.x, 0.0);
        expect(controller.view.pan.y, 0.0);
        expect(controller.view.zoom, 1.0);
        drainKnownShaderExceptions(tester);
      },
      skip: RuntimeModeService.useRendererPlaceholderSurface,
    );

    // Run this case with --dart-define=FORCE_GPU_RENDER=true to exercise the
    // actual first viewer frame instead of the automated-test placeholder.
    testWidgets(
      'Koch Snowflake viewer starts from its framed default view',
      (tester) async {
        await pumpApp(tester);
        await openModuleBySearch(
          tester,
          query: 'Koch Snowflake',
          displayName: 'Koch Snowflake',
          catalogId: 'core.koch_snowflake',
        );

        final renderer = find.byType(FractalRenderer);
        expect(renderer, findsOneWidget);
        final controller = Provider.of<FractalController>(
          tester.element(renderer),
          listen: false,
        );
        expect(controller.module.id, 'koch_snowflake');
        expect(controller.view.pan.x, 0.0);
        expect(controller.view.pan.y, 0.3);
        expect(controller.view.zoom, 1.2);
        drainKnownShaderExceptions(tester);
      },
      skip: RuntimeModeService.useRendererPlaceholderSurface,
    );

    for (final launch in [
      (
        query: 'Mandelbrot',
        name: 'Mandelbrot',
        id: 'core.mandelbrot',
        moduleId: 'mandelbrot'
      ),
      (
        query: 'Burning Ship',
        name: 'Burning Ship',
        id: 'core.burning_ship',
        moduleId: 'burning_ship'
      ),
      (
        query: 'Phoenix',
        name: 'Phoenix',
        id: 'core.phoenix',
        moduleId: 'phoenix'
      ),
      (
        query: 'Barnsley Fern',
        name: 'Barnsley Fern',
        id: 'core.barnsley_fern',
        moduleId: 'barnsley_fern'
      ),
      (
        query: 'Lorenz Attractor',
        name: 'Lorenz Attractor (2D)',
        id: 'core.lorenz_2d',
        moduleId: 'lorenz_2d'
      ),
    ]) {
      testWidgets(
        '${launch.name} viewer starts from its configured default view',
        (tester) async {
          await pumpApp(tester);
          await openModuleBySearch(
            tester,
            query: launch.query,
            displayName: launch.name,
            catalogId: launch.id,
          );

          final renderer = find.byType(FractalRenderer);
          expect(renderer, findsOneWidget);
          final controller = Provider.of<FractalController>(
            tester.element(renderer),
            listen: false,
          );
          expect(controller.module.id, launch.moduleId);
          final defaultView = controller.module.defaultPreset.view;
          expect(controller.view.pan.x, defaultView.pan.x);
          expect(controller.view.pan.y, defaultView.pan.y);
          expect(controller.view.zoom, defaultView.zoom);
          drainKnownShaderExceptions(tester);
        },
        skip: RuntimeModeService.useRendererPlaceholderSurface,
      );
    }
  });
}
