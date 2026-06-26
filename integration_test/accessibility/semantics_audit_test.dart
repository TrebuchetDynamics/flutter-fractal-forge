import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette_service.dart';
import 'package:flutter_fractals/main.dart';

// Re-use the semantics tree traversal helper from unit tests.
import '../../test/helpers/semantics_test_helper.dart';
import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Semantics Audit — Home / Catalog', () {
    testWidgets('Catalog screen has correct semantic properties',
        (WidgetTester tester) async {
      // --- Bootstrap services ---
      SharedPreferences.setMockInitialValues({});
      final results = await Future.wait([
        PresetStore.create(),
        HistoryStore.create(),
        AccessibilityService.create(),
        RendererSettingsService.create(),
        PaletteService.create(),
      ]);
      final presetStore = results[0] as PresetStore;
      final historyStore = results[1] as HistoryStore;
      final accessibilityService = results[2] as AccessibilityService;
      final rendererSettingsService = results[3] as RendererSettingsService;

      // --- Launch app ---
      await tester.pumpWidget(FlutterFractalsApp(
        presetStore: presetStore,
        historyStore: historyStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ));
      await pumpForAppBoot(tester);

      // --- Enable semantics ---
      final semanticsHandle = tester.ensureSemantics();
      await openCatalogSearchField(tester);

      // --- Extract & print the semantics narrative ---
      final narrative = extractSemanticsNarrative(tester);
      // ignore: avoid_print
      print('=== SEMANTICS NARRATIVE (Catalog Screen) ===');
      // ignore: avoid_print
      print(narrative);
      // ignore: avoid_print
      print('=== END NARRATIVE ===');

      // --- Structural assertions ---

      // 1. The search field should exist and be identifiable.
      expect(
        catalogSearchField(),
        findsOneWidget,
        reason: 'Catalog search field must be present',
      );

      // 2. At least one fractal card should have a semantic label.
      expect(
        find.bySemanticsLabel(RegExp(r'.*fractal.*', caseSensitive: false)),
        findsWidgets,
        reason: 'Fractal catalog cards must have semantic labels',
      );

      // 3. View toggle button must be present.
      expect(
        find.byIcon(Icons.view_list_rounded),
        findsOneWidget,
        reason: 'View toggle button must be present',
      );

      // 4. The narrative should not be empty.
      expect(narrative.trim().isNotEmpty, isTrue,
          reason: 'Semantics narrative must not be empty');

      // 5. Verify the narrative mentions at least one "isButton" flag
      //    (proof that interactive elements expose button semantics).
      expect(
        narrative.contains('isButton'),
        isTrue,
        reason:
            'At least one interactive element must expose isButton semantics',
      );

      // 6. Verify fractal module card keys are present for reliable
      //    non-visual identification.
      await enterCatalogSearch(
        tester,
        'Mandelbrot',
        settle: const Duration(milliseconds: 600),
      );
      expect(
        catalogModuleCard('core.mandelbrot'),
        findsOneWidget,
        reason:
            'Mandelbrot fractal card must be identifiable via ValueKey after filtering',
      );

      semanticsHandle.dispose();
    });
  });
}
