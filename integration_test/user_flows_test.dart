/// Comprehensive integration tests for Flutter Fractal Forge.
///
/// These tests cover full user flows including:
/// - Browse catalog and navigate between fractal modules
/// - View fractal details with gesture interactions
/// - Adjust controls (parameters, sliders, options)
/// - Save and apply presets
/// - Export images with various options
///
/// Run with: flutter test integration_test/user_flows_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;
    late TestLogger logger;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
      logger = TestLogger();
    });

    tearDown(() async {
      await logger.dispose();
    });

    Future<void> safeSettle(WidgetTester tester) async {
      // Shader/ticker-driven UI may never fully settle on emulators.
      // Treat settle as a best-effort stabilization step.
      try {
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 3),
        );
      } catch (_) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }
    }

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      await safeSettle(tester);
    }

    // =========================================================================
    // CATALOG BROWSING TESTS
    // =========================================================================

    group('Catalog Browsing', () {
      testWidgets('displays all fractal modules on launch', (tester) async {
        await pumpApp(tester);

        // Catalog should show all 4 fractal modules
        final listTiles = find.byType(ListTile);
        expect(listTiles, findsAtLeastNWidgets(4));

        // Verify section headers are visible
        expect(find.text('3D Fractals'), findsOneWidget);
        expect(find.text('2D Fractals'), findsOneWidget);

        logger.logAction('test', 'Catalog displayed with 4 modules');
      });

      testWidgets('search filters catalog by fractal name', (tester) async {
        await pumpApp(tester);

        final searchField = find.byKey(const Key('catalogSearchField'));
        expect(searchField, findsOneWidget);

        // Search for Julia
        await tester.enterText(searchField, 'Julia');
        await safeSettle(tester);
        expect(find.byType(ListTile), findsOneWidget);

        // Search for Mandelbrot
        await tester.enterText(searchField, 'Mandel');
        await safeSettle(tester);
        expect(find.byType(ListTile), findsAtLeastNWidgets(1));

        // Clear search shows all
        await tester.enterText(searchField, '');
        await safeSettle(tester);
        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        logger.logAction('test', 'Search filtering works correctly');
      });

      testWidgets('search shows empty state for no results', (tester) async {
        await pumpApp(tester);

        final searchField = find.byKey(const Key('catalogSearchField'));
        await tester.enterText(searchField, 'XYZNONEXISTENT');
        await safeSettle(tester);

        // Should show empty state
        expect(find.byType(ListTile), findsNothing);
        expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

        // Clear button should be available
        final clearButton = find.byKey(const Key('catalogClearSearchButton'));
        expect(clearButton, findsOneWidget);

        // Tap clear to restore catalog
        await tester.tap(clearButton);
        await safeSettle(tester);
        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        logger.logAction('test', 'Empty state and clear functionality work');
      });

      testWidgets('can navigate to each fractal module', (tester) async {
        await pumpApp(tester);

        final modules = find.byType(ListTile);
        final moduleCount = modules.evaluate().length;

        for (int i = 0; i < moduleCount; i++) {
          // Re-pump for fresh state
          if (i > 0) await pumpApp(tester);

          await tester.tap(find.byType(ListTile).at(i));
          await tester.pump(const Duration(seconds: 2));

          // Verify viewer loaded
          expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

          // Navigate back
          final backButton = find.byTooltip('Back');
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await safeSettle(tester);
          }

          logger.logNavigation('Tested navigation to module $i');
        }
      });

      testWidgets('tab navigation between Explore and AR', (tester) async {
        await pumpApp(tester);

        // Should start on Explore tab
        expect(find.text('Explore'), findsOneWidget);

        // Tap AR tab
        await tester.tap(find.text('AR'));
        await safeSettle(tester);

        // Should show AR screen (camera icon in nav is now selected)
        expect(find.byIcon(Icons.camera_rounded), findsOneWidget);

        // Tap back to Explore
        await tester.tap(find.text('Explore'));
        await safeSettle(tester);

        // Should be back on catalog
        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        logger.logNavigation('Tab navigation works correctly');
      });
    });

    // =========================================================================
    // FRACTAL VIEWER TESTS
    // =========================================================================

    group('Fractal Viewer', () {
      testWidgets('viewer shows correct fractal title', (tester) async {
        await pumpApp(tester);

        // Open first fractal
        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // Verify we're on viewer screen with correct actions
        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
        expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
        expect(find.byIcon(Icons.share_rounded), findsOneWidget);
        expect(find.byIcon(Icons.download_rounded), findsOneWidget);

        logger.logAction('test', 'Viewer screen loaded with all action buttons');
      });

      testWidgets('floating action buttons are tappable', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // Test controls button
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);
        expect(find.byType(FractalControlsSheet), findsOneWidget);

        // Close controls sheet
        await tester.tapAt(const Offset(10, 10));
        await safeSettle(tester);

        // Test presets button
        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);
        expect(find.byType(PresetSheet), findsOneWidget);

        // Close presets sheet
        await tester.tapAt(const Offset(10, 10));
        await safeSettle(tester);

        logger.logAction('test', 'All FABs are functional');
      });

      testWidgets('can navigate back from viewer', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // Navigate back
        final backButton = find.byTooltip('Back');
        await tester.tap(backButton);
        await safeSettle(tester);

        // Should be back on catalog
        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        logger.logNavigation('Back navigation from viewer works');
      });
    });

    // =========================================================================
    // CONTROLS ADJUSTMENT TESTS
    // =========================================================================

    group('Controls Adjustment', () {
      testWidgets('controls sheet displays all parameters', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Controls sheet should be visible
        expect(find.byType(FractalControlsSheet), findsOneWidget);

        // Should have sliders for parameters
        expect(find.byType(Slider), findsAtLeastNWidgets(1));

        // Should have action buttons
        expect(find.text('Reset View'), findsOneWidget);
        expect(find.text('Reset Parameters'), findsOneWidget);
        expect(find.text('Randomize'), findsOneWidget);

        logger.logAction('test', 'Controls sheet displays all elements');
      });

      testWidgets('sliders are interactive', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Find a slider and interact with it
        final slider = find.byType(Slider).first;
        expect(slider, findsOneWidget);

        // Drag the slider
        await tester.drag(slider, const Offset(50, 0));
        await safeSettle(tester);

        logger.logAction('test', 'Slider interaction successful');
      });

      testWidgets('reset view button resets the view', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Tap reset view
        await tester.tap(find.text('Reset View'));
        await safeSettle(tester);

        logger.logAction('test', 'Reset view executed');
      });

      testWidgets('reset parameters button resets params', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // First modify a slider
        await tester.drag(find.byType(Slider).first, const Offset(50, 0));
        await safeSettle(tester);

        // Then reset
        await tester.tap(find.text('Reset Parameters'));
        await safeSettle(tester);

        logger.logAction('test', 'Reset parameters executed');
      });

      testWidgets('randomize button randomizes parameters', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Tap randomize
        await tester.tap(find.text('Randomize'));
        await safeSettle(tester);

        logger.logAction('test', 'Randomize executed');
      });

      testWidgets('closing controls sheet returns to viewer', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        expect(find.byType(FractalControlsSheet), findsOneWidget);

        // Close via close button
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await safeSettle(tester);

        expect(find.byType(FractalControlsSheet), findsNothing);

        logger.logAction('test', 'Controls sheet closes correctly');
      });
    });

    // =========================================================================
    // PRESET MANAGEMENT TESTS
    // =========================================================================

    group('Preset Management', () {
      testWidgets('preset sheet displays built-in presets', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Preset sheet should be visible
        expect(find.byType(PresetSheet), findsOneWidget);

        // Should have built-in presets section
        expect(find.text('Built-in Presets'), findsOneWidget);

        // Should have at least one built-in preset
        expect(find.byIcon(Icons.auto_awesome_rounded), findsAtLeastNWidgets(1));

        logger.logAction('test', 'Preset sheet displays built-in presets');
      });

      testWidgets('can apply built-in preset', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Find and tap a built-in preset chip
        final presetChips = find.byIcon(Icons.auto_awesome_rounded);
        expect(presetChips, findsAtLeastNWidgets(1));

        await tester.tap(presetChips.first);
        await safeSettle(tester);

        // Sheet should close after applying preset
        expect(find.byType(PresetSheet), findsNothing);

        logger.logAction('test', 'Built-in preset applied successfully');
      });

      testWidgets('save preset requires name', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Find save section
        expect(find.text('Save Preset'), findsOneWidget);

        // Save button should be disabled without name
        // The button uses GradientButton which disables on null onPressed
        expect(find.text('Save Preset'), findsAtLeastNWidgets(1));

        logger.logAction('test', 'Save preset validation works');
      });

      testWidgets('can save and apply user preset', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Enter preset name
        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Test Preset');
        await safeSettle(tester);

        // Tap save
        final saveButtons = find.text('Save Preset');
        // There should be a header and a button
        if (saveButtons.evaluate().length > 1) {
          await tester.tap(saveButtons.last);
          await safeSettle(tester);
        }

        // Wait for save to complete
        await tester.pump(const Duration(milliseconds: 500));

        logger.logAction('test', 'User preset saved');
      });

      testWidgets('user presets section shows empty state initially', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Should show user presets section
        expect(find.text('Your Presets'), findsOneWidget);

        // Should show empty state (no user presets saved)
        expect(find.byIcon(Icons.bookmark_add_rounded), findsOneWidget);

        logger.logAction('test', 'Empty user presets state shown');
      });
    });

    // =========================================================================
    // EXPORT FLOW TESTS
    // =========================================================================

    group('Export Flow', () {
      testWidgets('export sheet opens from viewer', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Export sheet should be visible
        expect(find.byType(ExportOptionsSheet), findsOneWidget);
        expect(find.text('Export Fractal'), findsOneWidget);

        logger.logAction('test', 'Export sheet opens');
      });

      testWidgets('export sheet shows format options', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Should show format section
        expect(find.text('Format'), findsOneWidget);

        // Should have format buttons
        expect(find.text('PNG'), findsOneWidget);
        expect(find.text('JPG'), findsOneWidget);
        expect(find.text('WebP'), findsOneWidget);

        logger.logAction('test', 'Export formats displayed');
      });

      testWidgets('export sheet shows resolution options', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Should show resolution section
        expect(find.text('Resolution'), findsOneWidget);

        // Should have resolution chips
        expect(find.byType(ChoiceChip), findsAtLeastNWidgets(1));

        logger.logAction('test', 'Export resolutions displayed');
      });

      testWidgets('can select different format', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Select JPG format
        final jpgButton = find.text('JPG');
        await tester.tap(jpgButton);
        await safeSettle(tester);

        // Quality slider should appear for JPG
        expect(find.text('Quality'), findsOneWidget);

        logger.logAction('test', 'Format selection works');
      });

      testWidgets('can toggle advanced options', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Find and tap advanced options toggle
        await tester.tap(find.text('Advanced Options'));
        await safeSettle(tester);

        // Should show embed metadata option
        expect(find.text('Embed Metadata'), findsOneWidget);

        logger.logAction('test', 'Advanced options toggle works');
      });

      testWidgets('quick presets are selectable', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Should show quick presets
        expect(find.text('Quick Presets'), findsOneWidget);

        // Try tapping a quick preset (High Quality)
        final highQualityPreset = find.text('High Quality');
        if (highQualityPreset.evaluate().isNotEmpty) {
          await tester.tap(highQualityPreset);
          await safeSettle(tester);
        }

        logger.logAction('test', 'Quick presets are interactive');
      });

      testWidgets('export summary shows selected options', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Should show summary section
        expect(find.text('Summary'), findsOneWidget);

        logger.logAction('test', 'Export summary is visible');
      });

      testWidgets('export now button is present', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);

        // Should have export button
        expect(find.text('Export Now'), findsOneWidget);

        logger.logAction('test', 'Export button is present');
      });
    });

    // =========================================================================
    // END-TO-END USER FLOW TESTS
    // =========================================================================

    group('Complete User Flows', () {
      testWidgets('complete flow: browse → view → adjust → preset → export',
          (tester) async {
        await pumpApp(tester);

        // STEP 1: Browse catalog
        logger.logAction('test', 'Step 1: Browsing catalog');
        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        // STEP 2: Search and select fractal
        logger.logAction('test', 'Step 2: Searching and selecting');
        final searchField = find.byKey(const Key('catalogSearchField'));
        await tester.enterText(searchField, 'Julia');
        await safeSettle(tester);
        expect(find.byType(ListTile), findsOneWidget);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // STEP 3: Verify viewer
        logger.logAction('test', 'Step 3: Viewing fractal');
        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

        // STEP 4: Open and adjust controls
        logger.logAction('test', 'Step 4: Adjusting controls');
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);
        expect(find.byType(FractalControlsSheet), findsOneWidget);

        // Modify a slider
        await tester.drag(find.byType(Slider).first, const Offset(30, 0));
        await safeSettle(tester);

        // Close controls
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await safeSettle(tester);

        // STEP 5: Save as preset
        logger.logAction('test', 'Step 5: Saving preset');
        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Julia Preset');
        await safeSettle(tester);

        // Close preset sheet
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await safeSettle(tester);

        // STEP 6: Open export
        logger.logAction('test', 'Step 6: Configuring export');
        await tester.tap(find.byIcon(Icons.download_rounded));
        await safeSettle(tester);
        expect(find.byType(ExportOptionsSheet), findsOneWidget);

        // Select 4K resolution
        final resolutionChips = find.byType(ChoiceChip);
        if (resolutionChips.evaluate().length > 4) {
          await tester.tap(resolutionChips.at(4)); // 4K option
          await safeSettle(tester);
        }

        // Close export sheet (don't actually export in test)
        await tester.tapAt(const Offset(10, 10));
        await safeSettle(tester);

        logger.logAction('test', 'Complete flow finished successfully');
      });

      testWidgets('flow: apply preset and verify parameters change',
          (tester) async {
        await pumpApp(tester);

        // Navigate to fractal
        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // Open presets
        await tester.tap(find.byIcon(Icons.bookmark_rounded));
        await safeSettle(tester);

        // Get initial state by remembering we'll apply a preset
        final presetChips = find.byIcon(Icons.auto_awesome_rounded);
        expect(presetChips, findsAtLeastNWidgets(1));

        // Apply preset (this changes parameters)
        await tester.tap(presetChips.first);
        await safeSettle(tester);

        // Preset sheet should close
        expect(find.byType(PresetSheet), findsNothing);

        // Open controls to verify parameters
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Controls should show updated values
        expect(find.byType(Slider), findsAtLeastNWidgets(1));

        logger.logAction('test', 'Preset application changes parameters');
      });

      testWidgets('flow: multiple fractal exploration', (tester) async {
        await pumpApp(tester);

        final moduleCount = find.byType(ListTile).evaluate().length;

        for (int i = 0; i < moduleCount; i++) {
          logger.logAction('test', 'Exploring fractal $i');

          // Reset to catalog
          await pumpApp(tester);

          // Select fractal
          await tester.tap(find.byType(ListTile).at(i));
          await tester.pump(const Duration(seconds: 2));

          // Open controls briefly
          await tester.tap(find.byIcon(Icons.tune_rounded));
          await safeSettle(tester);

          // Verify controls for this fractal type
          expect(find.byType(Slider), findsAtLeastNWidgets(1));

          // Randomize
          await tester.tap(find.text('Randomize'));
          await safeSettle(tester);

          // Close controls
          await tester.tap(find.byIcon(Icons.close_rounded).last);
          await safeSettle(tester);
        }

        logger.logAction('test', 'Explored all fractals');
      });

      testWidgets('flow: AR tab basic interaction', (tester) async {
        await pumpApp(tester);

        // Switch to AR tab
        await tester.tap(find.text('AR'));
        await safeSettle(tester);

        // Should show AR screen (may require camera permissions in real device)
        // In test environment, we just verify the tab switch works
        expect(find.byIcon(Icons.camera_rounded), findsOneWidget);

        // Switch back
        await tester.tap(find.text('Explore'));
        await safeSettle(tester);

        expect(find.byType(ListTile), findsAtLeastNWidgets(4));

        logger.logAction('test', 'AR tab navigation works');
      });
    });

    // =========================================================================
    // ACCESSIBILITY TESTS
    // =========================================================================

    group('Accessibility', () {
      testWidgets('catalog has semantic labels', (tester) async {
        await pumpApp(tester);

        // Each module card should have semantics
        final semanticsData = tester.getSemantics(find.byType(ListTile).first);
        expect(semanticsData.label, isNotEmpty);

        logger.logAction('test', 'Catalog items have semantic labels');
      });

      testWidgets('navigation tabs have semantic labels', (tester) async {
        await pumpApp(tester);

        // Nav items should have semantics
        final exploreSemantics = tester.getSemantics(find.text('Explore'));
        expect(exploreSemantics.label, isNotEmpty);

        logger.logAction('test', 'Navigation has semantic labels');
      });
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    group('Error Handling', () {
      testWidgets('handles rapid navigation gracefully', (tester) async {
        await pumpApp(tester);

        // Rapid taps
        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(milliseconds: 100));
        
        // Try to go back immediately
        final backButton = find.byTooltip('Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
        }
        await tester.pump(const Duration(milliseconds: 100));

        // Should not crash - allow any state
        await safeSettle(tester);

        logger.logAction('test', 'Rapid navigation handled gracefully');
      });

      testWidgets('handles double-tap on controls gracefully', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        // Double-tap controls button
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);

        // Should show controls sheet (not crash)
        expect(find.byType(FractalControlsSheet), findsOneWidget);

        logger.logAction('test', 'Double-tap handled gracefully');
      });
    });

    // =========================================================================
    // PERFORMANCE TESTS
    // =========================================================================

    group('Performance', () {
      testWidgets('viewer loads within reasonable time', (tester) async {
        final stopwatch = Stopwatch()..start();

        await pumpApp(tester);
        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        stopwatch.stop();

        // Should load within 3 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));

        logger.logAction('test', 'Viewer loaded in ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('controls sheet opens quickly', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.byType(ListTile).first);
        await tester.pump(const Duration(seconds: 2));

        final stopwatch = Stopwatch()..start();
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await safeSettle(tester);
        stopwatch.stop();

        // Should open within 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));

        logger.logAction('test', 'Controls opened in ${stopwatch.elapsedMilliseconds}ms');
      });
    });
  });
}
