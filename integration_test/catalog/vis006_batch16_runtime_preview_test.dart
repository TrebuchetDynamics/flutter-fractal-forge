import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VIS-006 batch 16 runtime catalog previews capture GPU pixels',
      (tester) async {
    CatalogRuntimeThumbnailCache.clearForTesting();
    SharedPreferences.setMockInitialValues({});
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
    await tester.pump();

    const entries = <(String, String)>[
      ('core.secant_cosecant', 'Secant/Cosecant Map'),
      ('core.taylor', 'Taylor Series Fractal'),
      ('core.rational_map', 'Rational Map Fractal'),
      ('core.lattes_map_julia', 'Lattès Map Julia Set'),
      ('core.complex_henon_julia_slice', 'Complex Hénon Julia Slice'),
      ('core.matrix_logistic_spectrum', 'Matrix Logistic Spectrum'),
      ('core.barnsley_j2', 'Barnsley J2'),
      ('core.barnsley_j3', 'Barnsley J3'),
      ('core.celtic_julia', 'Celtic Julia'),
      ('core.buffalo_julia', 'Buffalo Julia'),
    ];

    for (final (catalogId, searchText) in entries) {
      await enterCatalogSearch(tester, searchText);
      final thumbnail = find.byKey(Key('catalogCachedThumbnail_$catalogId'));
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (
          thumbnail.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(thumbnail, findsOneWidget,
          reason: 'Missing preview for $catalogId');

      final imageWidget = tester.widget<Image>(thumbnail);
      var provider = imageWidget.image;
      while (provider is ResizeImage) {
        provider = provider.imageProvider;
      }
      final bytes = (provider as MemoryImage).bytes;
      expect(bytes, isNotEmpty, reason: 'Empty preview for $catalogId');
      final image = img.decodeImage(bytes);
      expect(image, isNotNull, reason: 'Undecodable preview for $catalogId');
      final metrics =
          RenderAuditMetrics.fromImage(image!, pngBytes: bytes.length);
      expect(metrics.verdict, 'pass', reason: 'Preview quality for $catalogId');

      const outputDirectory = 'build/test_output/vis006-batch16';
      await Directory(outputDirectory).create(recursive: true);
      final output = File(
        '$outputDirectory/${catalogId.split('.').last}_runtime_catalog_preview.png',
      );
      await output.writeAsBytes(bytes, flush: true);
      // ignore: avoid_print
      print(
        'runtime_catalog_preview=${output.path} catalogId=$catalogId '
        'dimensions=${image.width}x${image.height} metrics=${metrics.toJson()}',
      );
    }
  },
      skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS') ||
          RuntimeModeService.useRendererPlaceholderSurface);
}
