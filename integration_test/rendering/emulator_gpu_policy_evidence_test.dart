import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart' as app;

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('emulator auto policy probes three representative 2D fractals',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await app.main();
    await pumpForAppBoot(tester);

    for (final catalogId in <String>[
      'core.mandelbrot',
      'core.burning_ship',
      'core.tricorn',
    ]) {
      await enterCatalogSearch(tester, catalogId);
      final target = catalogModuleCard(catalogId);
      expect(target, findsOneWidget);
      debugPrint('[integration] opening_catalog_id=$catalogId');

      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FractalViewerScreen), findsOneWidget,
          reason: 'Viewer did not open for $catalogId');

      // Wait long enough for the 2s GPU health probe timer + sampling work.
      await tester.pump(const Duration(seconds: 6));

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
