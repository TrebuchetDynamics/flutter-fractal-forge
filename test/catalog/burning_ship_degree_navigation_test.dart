import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final collection in ['@favorites', '@recent']) {
    testWidgets('$collection keeps old degree cards replayable',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'catalog_browse_collection': collection,
        'catalog_favorite_ids': ['core.f0114_burning_ship_d_8'],
        'catalog_recent_ids': ['core.f0114_burning_ship_d_8'],
      });
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      addTearDown(controller.dispose);
      var opened = false;
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FractalCatalogScreen(
              onOpenViewer: (duration, family) => opened = true,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final oldCard = find
          .byKey(const Key('catalogModuleCard_core.f0114_burning_ship_d_8'));
      expect(oldCard, findsOneWidget);
      await tester.tap(oldCard);
      await tester.pump();
      expect(opened, isTrue);
      expect(controller.module.id, 'burning_ship');
      expect(controller.params['power'], 8.0);

      await tester.tap(find.byKey(const Key('catalogCollectionChip_explore')));
      await tester.pump();
      expect(oldCard, findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('catalog_favorite_ids'),
          ['core.f0114_burning_ship_d_8']);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
    });
  }
}
