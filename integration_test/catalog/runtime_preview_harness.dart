import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

class RuntimePreviewTarget {
  const RuntimePreviewTarget(this.id, this.search, this.outputName);
  final String id;
  final String search;
  final String outputName;
}

void registerRuntimePreview(
  List<RuntimePreviewTarget> targets,
  String outputDir, {
  required String description,
  bool perTargetTests = false,
}) {
  Future<void> setup(WidgetTester tester) async {
    CatalogRuntimeThumbnailCache.clearForTesting();
    SharedPreferences.setMockInitialValues({});
    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();
    await tester.pumpWidget(FlutterFractalsApp(
      presetStore: presetStore,
      accessibilityService: accessibilityService,
      rendererSettingsService: rendererSettingsService,
      locale: const Locale('en'),
    ));
    await tester.pump();
  }

  Future<void> capture(WidgetTester tester, RuntimePreviewTarget target) async {
    await enterCatalogSearch(tester, target.search);
    final thumbnail = find.byKey(Key('catalogCachedThumbnail_${target.id}'));
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (thumbnail.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(thumbnail, findsOneWidget,
        reason: 'Missing preview for ${target.id}');
    final imageWidget = tester.widget<Image>(thumbnail);
    var provider = imageWidget.image;
    while (provider is ResizeImage) {
      provider = provider.imageProvider;
    }
    final bytes = (provider as MemoryImage).bytes;
    expect(bytes, isNotEmpty, reason: 'Empty preview for ${target.id}');
    final image = img.decodeImage(bytes);
    expect(image, isNotNull, reason: 'Undecodable preview for ${target.id}');
    final metrics =
        RenderAuditMetrics.fromImage(image!, pngBytes: bytes.length);
    expect(metrics.verdict, 'pass', reason: 'Preview quality for ${target.id}');
    final outputDirectory = Directory(
      outputDir.replaceAll('{outputName}', target.outputName),
    );
    await outputDirectory.create(recursive: true);
    final fileName =
        perTargetTests || target.outputName == 'runtime_catalog_preview'
            ? 'runtime_catalog_preview'
            : '${target.outputName}_runtime_catalog_preview';
    final output = File('${outputDirectory.path}/$fileName.png');
    await output.writeAsBytes(bytes, flush: true);
    // ignore: avoid_print
    print('runtime_catalog_preview=${output.path} catalogId=${target.id} '
        'dimensions=${image.width}x${image.height} metrics=${metrics.toJson()}');
  }

  final skip =
      !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS') ||
          RuntimeModeService.useRendererPlaceholderSurface;
  if (perTargetTests) {
    for (final target in targets) {
      testWidgets(description.replaceAll('{id}', target.id), (tester) async {
        await setup(tester);
        await capture(tester, target);
      }, skip: skip);
    }
  } else {
    testWidgets(description, (tester) async {
      await setup(tester);
      for (final target in targets) {
        await capture(tester, target);
      }
    }, skip: skip);
  }
}
