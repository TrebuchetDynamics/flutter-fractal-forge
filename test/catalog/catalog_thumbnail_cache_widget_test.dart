import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_cache.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// 1x1 transparent PNG - decodes fine, keeps the test hermetic.
final Uint8List kTinyPng = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x62,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

Future<void> pumpCatalog(WidgetTester tester, ModuleRegistry registry) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CatalogThumbnailCache.clearForTesting();
  });

  testWidgets('every visible tile serves cached pixels on a warm cache',
      (tester) async {
    final registry = ModuleRegistry();
    final repo = CatalogRepository.fromRegistry(registry);
    // Seed every entry: the whole catalog behaves like a second visit.
    for (final entry in repo.entries) {
      final signature = CatalogThumbnailCache.renderSignatureForModule(
        entry.catalogId,
        entry.module,
      );
      await CatalogThumbnailCache.store(signature, kTinyPng);
    }

    await pumpCatalog(tester, registry);

    // Visible tiles serve the cached bytes instead of rendering.
    final cachedTiles = find.byWidgetPredicate((widget) {
      if (widget is! Image) return false;
      final key = widget.key;
      return key is Key && key.toString().contains('catalogCachedThumbnail_');
    });
    expect(
      cachedTiles,
      findsWidgets,
      reason: 'a fully seeded cache should serve visible tiles from memory',
    );
  });

  testWidgets('a cold cache serves no cached thumbnails', (tester) async {
    final registry = ModuleRegistry();

    await pumpCatalog(tester, registry);

    final cachedTiles = find.byWidgetPredicate((widget) {
      if (widget is! Image) return false;
      final key = widget.key;
      return key is Key && key.toString().contains('catalogCachedThumbnail_');
    });
    expect(cachedTiles, findsNothing);
  });
}
