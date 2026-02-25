/// Generates GPU-rendered catalog thumbnails on emulator.
///
/// Run:
///   flutter test integration_test/generate_gpu_thumbnails_test.dart -d emulator-5554
library;

import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate GPU thumbnails', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });
    final presetStore = await PresetStore.create();
    final arQualityStore = await ArQualityStore.create();
    final accessibilityService = await AccessibilityService.create();
    final registry = ModuleRegistry();

    int generated = 0;
    int failed = 0;

    // Required for takeScreenshot on Android
    try {
      await binding.convertFlutterSurfaceToImage();
    } on MissingPluginException {
      debugPrint(
        'Screenshot plugin unavailable; skipping GPU thumbnail generation',
      );
      return;
    }

    // Android writes to external storage for adb pull; desktop writes locally.
    final outDir = Platform.isAndroid
        ? Directory('/sdcard/Download/catalog_thumbs')
        : Directory('build/test_output/catalog_thumbs');
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    for (final config in escapeTimeCatalog) {
      try {
        final module = registry.modules.firstWhere(
          (m) => m.id == config.id,
          orElse: () => buildEscapeTimeModule(config),
        );

        final controller = FractalController(registry);
        controller.selectModule(module);

        // Zoom to show fractal features - 5.0 shows edge detail without going into black interior
        controller.updateZoom(5.0);

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider.value(
              value: controller,
              child: const SizedBox(
                width: 256,
                height: 256,
                child: const FractalRenderer(),
              ),
            ),
          ),
        );

        // Let shader compile and render
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Take screenshot
        final bytes = await binding.takeScreenshot('thumb_${config.id}');
        final screenshot = img.decodeImage(Uint8List.fromList(bytes));

        if (screenshot != null) {
          // Resize to 256x256 if needed
          final thumb = screenshot.width == 256 && screenshot.height == 256
              ? screenshot
              : img.copyResize(screenshot, width: 256, height: 256);

          File('${outDir.path}/${config.id}.png')
              .writeAsBytesSync(img.encodePng(thumb));
          generated++;
          if (generated % 20 == 0)
            debugPrint('  Progress: $generated/${escapeTimeCatalog.length}');
        } else {
          debugPrint('  FAIL ${config.id}: decode failed');
          failed++;
        }

        controller.dispose();
      } catch (e) {
        if (e is MissingPluginException) {
          debugPrint(
            'Screenshot plugin unavailable during capture; '
            'skipping GPU thumbnail generation',
          );
          return;
        }
        debugPrint('  ERROR ${config.id}: $e');
        failed++;
      }
    }

    debugPrint('\n=== GPU Thumbnail Generation ===');
    debugPrint(
        'Generated: $generated / Failed: $failed / Total: ${escapeTimeCatalog.length}');
  });
}
