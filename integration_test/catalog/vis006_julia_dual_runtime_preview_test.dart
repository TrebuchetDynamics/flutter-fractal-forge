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

  testWidgets(
    'Julia Dual runtime catalog preview captures real GPU pixels',
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
      await enterCatalogSearch(tester, 'Mandelbrot + Julia');

      final thumbnail = find.byKey(
        const Key('catalogCachedThumbnail_core.julia_dual'),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (
          thumbnail.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(thumbnail, findsOneWidget);

      final imageWidget = tester.widget<Image>(thumbnail);
      var provider = imageWidget.image;
      while (provider is ResizeImage) {
        provider = provider.imageProvider;
      }
      final bytes = (provider as MemoryImage).bytes;
      expect(bytes, isNotEmpty);
      final image = img.decodeImage(bytes);
      expect(image, isNotNull);
      final metrics = RenderAuditMetrics.fromImage(
        image!,
        pngBytes: bytes.length,
      );
      expect(metrics.verdict, 'pass');

      const outputDirectory = 'build/test_output/vis006-julia-dual';
      await Directory(outputDirectory).create(recursive: true);
      final output = File('$outputDirectory/runtime_catalog_preview.png');
      await output.writeAsBytes(bytes, flush: true);
      // ignore: avoid_print
      print(
        'julia_dual_runtime_catalog_preview=${output.path} '
        'selected=1 generated=1 failed=0 backend=gpu '
        'dimensions=${image.width}x${image.height} '
        'metrics=${metrics.toJson()}',
      );
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS') ||
        RuntimeModeService.useRendererPlaceholderSurface,
  );
}
