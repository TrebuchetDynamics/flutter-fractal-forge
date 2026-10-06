/// Smoke test: verify catalog thumbnails load from assets in integration mode.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Catalog thumbnails load', (tester) async {
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
    await tester.pump(const Duration(seconds: 3));

    // App now starts directly on catalog; verify catalog cards are present.
    expect(catalogModuleCards(), findsWidgets);

    final approximatePreviews = find.text('Preview approximate');
    debugPrint(
        'Runtime fallback thumbnails found: ${approximatePreviews.evaluate().length}');

    // Static catalog_thumbs assets are intentionally not bundled; test mode
    // renders the lightweight approximate preview instead.
    expect(approximatePreviews, findsWidgets);
  });

  // Run with --dart-define=FORCE_GPU_RENDER=true and
  // --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true to verify an actual
  // catalog tile render and archive its captured pixels.
  testWidgets(
    'Julia runtime catalog preview captures real GPU pixels',
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
      await enterCatalogSearch(tester, 'Julia');

      final thumbnail = find.byKey(
        const Key('catalogCachedThumbnail_core.julia'),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (
          thumbnail.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(thumbnail, findsOneWidget);

      final image = tester.widget<Image>(thumbnail);
      var imageProvider = image.image;
      while (imageProvider is ResizeImage) {
        imageProvider = imageProvider.imageProvider;
      }
      final bytes = (imageProvider as MemoryImage).bytes;
      expect(bytes, isNotEmpty);

      final outputDirectory = Directory(
        'build/test_output/catalog-runtime-preview-${DateTime.now().microsecondsSinceEpoch}',
      );
      await outputDirectory.create(recursive: true);
      final output = File('${outputDirectory.path}/julia.png');
      await output.writeAsBytes(bytes, flush: true);
      // Keep the output location discoverable in integration-test logs.
      // ignore: avoid_print
      print('runtime_catalog_preview=${output.path} bytes=${bytes.length}');
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS') ||
        RuntimeModeService.useRendererPlaceholderSurface,
  );

  testWidgets(
    'Nova, Newton z3, and Koch Snowflake runtime catalog previews capture real GPU pixels',
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

      final outputDirectory = Directory(
        'build/test_output/catalog-runtime-preview-${DateTime.now().microsecondsSinceEpoch}',
      );
      await outputDirectory.create(recursive: true);

      Future<void> capture(
          String query, String catalogId, String fileName) async {
        await enterCatalogSearch(tester, query);
        final thumbnail = find.byKey(Key('catalogCachedThumbnail_$catalogId'));
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (
            thumbnail.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(thumbnail, findsOneWidget);

        final image = tester.widget<Image>(thumbnail);
        var imageProvider = image.image;
        while (imageProvider is ResizeImage) {
          imageProvider = imageProvider.imageProvider;
        }
        final bytes = (imageProvider as MemoryImage).bytes;
        expect(bytes, isNotEmpty);

        final output = File('${outputDirectory.path}/$fileName.png');
        await output.writeAsBytes(bytes, flush: true);
        // ignore: avoid_print
        print('runtime_catalog_preview=${output.path} bytes=${bytes.length}');
      }

      await capture('Nova', 'core.nova', 'nova');
      await capture('Newton', 'core.newton_z3', 'newton_z3');
      await capture('Koch Snowflake', 'core.koch_snowflake', 'koch_snowflake');
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS') ||
        RuntimeModeService.useRendererPlaceholderSurface,
  );
}
