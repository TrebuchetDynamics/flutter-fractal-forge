import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_render_gate.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'runtime thumbnail capture timeout advances the render queue',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      CatalogRuntimeThumbnailCache.clearForTesting();
      final registry = ModuleRegistry();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ModuleRegistry>.value(value: registry),
            ChangeNotifierProvider<FractalController>(
              create: (_) => FractalController(registry),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: FractalCatalogScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Widget tests cannot complete a real GPU readback, which deterministically
      // exercises the same hanging-capture path seen on affected devices.
      final queuedBeforeTimeout = CatalogThumbnailRenderGate.queuedForTesting;
      expect(
        CatalogThumbnailRenderGate.activeForTesting,
        CatalogThumbnailRenderGate.maxConcurrent,
      );
      expect(queuedBeforeTimeout, greaterThan(0));

      await tester.runAsync(
        () => Future<void>.delayed(
          CatalogThumbnailCapturePolicy.readbackTimeout +
              const Duration(milliseconds: 200),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        CatalogThumbnailRenderGate.queuedForTesting,
        lessThan(queuedBeforeTimeout),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS'),
  );
}
