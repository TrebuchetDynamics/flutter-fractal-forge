import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/main.dart';

/// Critical User Journey integration test.
///
/// Exercises the most important end-to-end user flow:
///   App launch -> catalog screen -> tap fractal card -> viewer loads ->
///   verify controls -> tap export -> verify export sheet -> go back.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical User Journey', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
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
        ArQualityStore.create(),
        HistoryStore.create(),
        AccessibilityService.create(),
        RendererSettingsService.create(),
        PaletteService.create(),
      ]);
      presetStore = results[0] as PresetStore;
      arQualityStore = results[1] as ArQualityStore;
      historyStore = results[2] as HistoryStore;
      accessibilityService = results[3] as AccessibilityService;
      rendererSettingsService = results[4] as RendererSettingsService;
    });

    /// Pumps the full app and waits for initial frames to render.
    ///
    /// Uses bounded pumps instead of pumpAndSettle because shader/animation
    /// frames may never fully settle.
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        historyStore: historyStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ));
      // Bounded pumps — shader animations never fully settle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
    }

    /// Drains known SkSL shader compilation exceptions that do not indicate
    /// real failures on emulators/CI.
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

    testWidgets(
      'launch -> catalog -> tap Mandelbrot -> viewer controls -> export -> back',
      (WidgetTester tester) async {
        final semantics = tester.ensureSemantics();

        // ------------------------------------------------------------------
        // Step 1: App launches and catalog screen appears
        // ------------------------------------------------------------------
        await pumpApp(tester);

        // The catalog search field confirms we are on the catalog screen.
        expect(
          find.byKey(const Key('catalogSearchField')),
          findsOneWidget,
          reason: 'Catalog screen must show the search field after launch',
        );

        // ------------------------------------------------------------------
        // Step 2: Verify catalog has fractal entries
        // ------------------------------------------------------------------
        // Mandelbrot should be present as it is the default first fractal.
        final mandelbrotCard =
            find.byKey(const Key('catalogModuleCard_core.mandelbrot'));
        expect(
          mandelbrotCard,
          findsOneWidget,
          reason: 'Mandelbrot fractal card must appear in catalog',
        );

        // Verify at least a few fractal entries are visible.
        final catalogCards = find.byWidgetPredicate((w) {
          final k = w.key;
          if (k is! ValueKey) return false;
          final v = k.value;
          if (v is! String) return false;
          return v.startsWith('catalogModuleCard_') ||
              v.startsWith('catalogGridTile_');
        });
        expect(
          catalogCards.evaluate().length,
          greaterThanOrEqualTo(4),
          reason: 'Catalog should show at least 4 fractal entries',
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
        // Controls button (tune icon)
        expect(
          find.byKey(const Key('viewerControlsButton')),
          findsOneWidget,
          reason: 'Viewer controls button (tune) must be present',
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
          find.byKey(const Key('catalogSearchField')),
          findsOneWidget,
          reason: 'Must return to catalog screen after pressing back',
        );

        semantics.dispose();
      },
    );
  });
}
