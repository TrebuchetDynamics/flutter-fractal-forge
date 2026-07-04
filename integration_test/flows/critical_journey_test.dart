import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

/// Critical User Journey integration test.
///
/// Exercises the most important end-to-end user flow:
///   App launch -> catalog screen -> tap fractal card -> viewer loads ->
///   verify controls -> tap export -> verify export sheet -> go back.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical User Journey', () {
    late PresetStore presetStore;
    late HistoryStore historyStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      final results = await Future.wait([
        PresetStore.create(),
        HistoryStore.create(),
        AccessibilityService.create(),
        RendererSettingsService.create(),
        PaletteService.create(),
      ]);
      presetStore = results[0] as PresetStore;
      historyStore = results[1] as HistoryStore;
      accessibilityService = results[2] as AccessibilityService;
      rendererSettingsService = results[3] as RendererSettingsService;
    });

    /// Pumps the full app and waits for initial frames to render.
    ///
    /// Uses bounded pumps instead of pumpAndSettle because shader/animation
    /// frames may never fully settle.
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(FlutterFractalsApp(
        presetStore: presetStore,
        historyStore: historyStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ));
      await pumpForAppBoot(tester);
    }

    testWidgets(
      'launch -> catalog -> tap Mandelbrot -> viewer controls -> export -> back',
      (WidgetTester tester) async {
        final semantics = tester.ensureSemantics();

        // ------------------------------------------------------------------
        // Step 1: App launches and catalog screen appears
        // ------------------------------------------------------------------
        await pumpApp(tester);

        // The catalog may sort/group entries dynamically, so assert the
        // screen surface first, then narrow to Mandelbrot via search.
        expect(
          catalogModuleCards(),
          findsWidgets,
          reason: 'Catalog screen must show fractal entries after launch',
        );

        // ------------------------------------------------------------------
        // Step 2: Verify catalog has fractal entries
        // ------------------------------------------------------------------
        expect(
          catalogModuleCards().evaluate().length,
          greaterThanOrEqualTo(4),
          reason: 'Catalog should show at least 4 fractal entries',
        );

        await enterCatalogSearch(
          tester,
          'Mandelbrot',
          settle: const Duration(milliseconds: 600),
        );

        final mandelbrotCard = catalogModuleCard('core.mandelbrot');
        expect(
          mandelbrotCard,
          findsOneWidget,
          reason: 'Mandelbrot fractal card must appear after filtering',
        );

        // ------------------------------------------------------------------
        // Step 3: Tap on Mandelbrot card to open viewer
        // ------------------------------------------------------------------
        await tester.tap(mandelbrotCard);
        // Shader animation frames may never settle; use bounded pumps.
        await tester.pump(const Duration(seconds: 2));
        drainKnownShaderExceptions(tester);

        // ------------------------------------------------------------------
        // Step 4: Verify viewer screen loaded
        // ------------------------------------------------------------------
        // The viewer has a back arrow, tune (controls), and download (export)
        // icons visible by default.
        expect(
          find.byIcon(Icons.arrow_back_rounded),
          findsOneWidget,
          reason: 'Viewer must show back button',
        );

        // ------------------------------------------------------------------
        // Step 5: Verify viewer controls are present
        // ------------------------------------------------------------------
        // Randomize params button (long-press opens controls)
        expect(
          find.byKey(const Key('viewerRandomParamsButton')),
          findsOneWidget,
          reason: 'Viewer randomize params button must be present',
        );

        // Export button (download icon)
        expect(
          find.byKey(const Key('viewerExportButton')),
          findsOneWidget,
          reason: 'Viewer export button (download) must be present',
        );

        // Random fractal button (shuffle icon)
        expect(
          find.byKey(const Key('viewerRandomButton')),
          findsOneWidget,
          reason: 'Viewer random button must be present',
        );

        // ------------------------------------------------------------------
        // Step 6: Tap export button and verify export sheet appears
        // ------------------------------------------------------------------
        await tester.tap(find.byKey(const Key('viewerExportButton')));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(milliseconds: 500));

        // The ExportOptionsSheet should now be visible as a modal bottom sheet.
        expect(
          find.byType(ExportOptionsSheet),
          findsOneWidget,
          reason: 'Export options sheet must appear after tapping export',
        );

        // Verify the Save and Share action buttons are present inside the sheet.
        expect(
          find.byKey(const Key('exportSaveButton')),
          findsOneWidget,
          reason: 'Export save button must be present in export sheet',
        );
        expect(
          find.byKey(const Key('exportShareButton')),
          findsOneWidget,
          reason: 'Export share button must be present in export sheet',
        );

        // Dismiss the export sheet by tapping the scrim / pressing back.
        // Navigator.pop closes the modal bottom sheet.
        final navigatorState = Navigator.of(
          tester.element(find.byType(ExportOptionsSheet)),
        );
        navigatorState.pop();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Export sheet should be dismissed.
        expect(
          find.byType(ExportOptionsSheet),
          findsNothing,
          reason: 'Export sheet must be dismissed after pop',
        );

        // ------------------------------------------------------------------
        // Step 7: Go back to catalog
        // ------------------------------------------------------------------
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Confirm we are back on the catalog screen.
        expect(
          catalogModuleCards(),
          findsWidgets,
          reason: 'Must return to the catalog module list after pressing back',
        );

        semantics.dispose();
      },
    );
  });
}
