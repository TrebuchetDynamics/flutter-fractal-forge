import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Viewer navigation and dialog smoke test', (tester) async {
    // 1. Setup
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });

    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ),
    );
    await pumpForAppBoot(tester);

    // 2. Open Catalog
    expect(catalogModuleCards(), findsWidgets);

    await enterCatalogSearch(
      tester,
      'Mandelbrot',
      settle: const Duration(milliseconds: 600),
    );

    final fractalCard = catalogModuleCard('core.mandelbrot');
    expect(fractalCard, findsOneWidget);
    await tester.tap(fractalCard);

    await tester.pump(const Duration(seconds: 2));
    drainKnownShaderExceptions(tester);

    // 3. Verify Viewer matches
    expect(find.byKey(const Key('viewerControlsButton')), findsOneWidget);
    debugPrint('Viewer loaded successfully');

    // 4. Open Controls (tune icon)
    final tuneIcon = find.byIcon(Icons.tune_rounded);
    expect(tuneIcon, findsOneWidget);
    await tester.tap(tuneIcon.first);

    await pumpForUiTransition(
      tester,
      settle: const Duration(milliseconds: 300),
    );

    // Verify controls sheet content
    expect(find.text('Controls'), findsWidgets);
    debugPrint('Controls sheet opened successfully');

    await tester.tapAt(const Offset(10, 10));
    await pumpForUiTransition(
      tester,
      settle: const Duration(milliseconds: 300),
    );

    // 5. Open Presets (bookmark icon)
    await openViewerPresets(
      tester,
      settle: const Duration(milliseconds: 300),
    );

    // Verify presets sheet
    expect(find.text('Presets'), findsOneWidget);
    debugPrint('Presets sheet opened successfully');

    // Close presets
    await tester.tapAt(const Offset(10, 10));
    await pumpForUiTransition(
      tester,
      settle: const Duration(milliseconds: 300),
    );

    debugPrint('Test completed successfully');
  });
}
