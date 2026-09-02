import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'rapid scrolling gives visible thumbnails live render slots',
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

      final catalog = find.byType(CustomScrollView);
      for (var attempt = 0;
          attempt < 20 && find.text('Barnsley Fern').evaluate().isEmpty;
          attempt++) {
        await tester.drag(catalog, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('Barnsley Fern'), findsOneWidget);
      await tester.ensureVisible(find.text('Barnsley Fern'));
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      const visibleCatalogIds = [
        'core.barnsley_fern',
        'core.barnsley_j1',
        'core.barnsley_j2',
        'core.barnsley_j3',
      ];
      final visibleRendererCount = visibleCatalogIds.fold<int>(
        0,
        (count, catalogId) =>
            count +
            find
                .descendant(
                  of: find.byKey(
                    Key('catalogRuntimeThumbnail_$catalogId'),
                  ),
                  matching: find.byType(FractalRenderer),
                )
                .evaluate()
                .length,
      );
      expect(visibleRendererCount, greaterThan(0));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS'),
  );
}
