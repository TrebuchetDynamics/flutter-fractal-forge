import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_offscreen_renderer.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fourier capture reads nonblank representative renderer pixels',
      (tester) async {
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
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(catalogModuleCards().first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final context = tester.element(find.byType(FractalRenderer));
    final controller = Provider.of<FractalController>(context, listen: false);

    final replay = FourierOffscreenRenderer();
    for (final moduleId in <String>[
      'mandelbrot',
      'cantor_dust',
      'sierpinski_carpet',
      'tortoise_toroidal_fractal',
    ]) {
      controller.selectModule(controller.registry.byId(moduleId),
          animate: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      final renderer =
          tester.widget<FractalRenderer>(find.byType(FractalRenderer).first);
      final snapshot = renderer.renderSnapshotSink?.snapshot;
      expect(snapshot, isNotNull,
          reason: '$moduleId effective render snapshot');
      expect(snapshot!.module.id, moduleId,
          reason: '$moduleId snapshot must not reuse the previous module');

      final stopwatch = Stopwatch()..start();
      final image = await replay.render(
        snapshot: snapshot,
        width: 128,
        height: 96,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      stopwatch.stop();
      expect(data, isNotNull, reason: '$moduleId raw RGBA readback');

      final bytes = data!.buffer.asUint8List();
      final imageWidth = image.width;
      final imageHeight = image.height;
      var alphaPixels = 0;
      var luminanceSum = 0.0;
      var luminanceSquaredSum = 0.0;
      var minLuminance = 255.0;
      var maxLuminance = 0.0;
      final colors = <int>{};
      for (var offset = 0; offset + 3 < bytes.length; offset += 4) {
        final alpha = bytes[offset + 3];
        if (alpha == 0) continue;
        alphaPixels++;
        final luminance = bytes[offset] * 0.2126 +
            bytes[offset + 1] * 0.7152 +
            bytes[offset + 2] * 0.0722;
        luminanceSum += luminance;
        luminanceSquaredSum += luminance * luminance;
        minLuminance = math.min(minLuminance, luminance);
        maxLuminance = math.max(maxLuminance, luminance);
        if (colors.length < 4096) {
          colors.add(
            (bytes[offset] << 16) |
                (bytes[offset + 1] << 8) |
                bytes[offset + 2],
          );
        }
      }
      image.dispose();

      expect(alphaPixels, greaterThan(0), reason: '$moduleId alpha coverage');
      final mean = luminanceSum / alphaPixels;
      final variance = luminanceSquaredSum / alphaPixels - mean * mean;
      expect(colors.length, greaterThan(16),
          reason: '$moduleId unique sampled colors');
      expect(maxLuminance - minLuminance, greaterThan(8),
          reason: '$moduleId luminance range');
      expect(variance, greaterThan(1), reason: '$moduleId luminance variance');
      debugPrint(
        '[fourier-capture] module=$moduleId width=$imageWidth '
        'height=$imageHeight alphaPixels=$alphaPixels '
        'mean=${mean.toStringAsFixed(3)} variance=${variance.toStringAsFixed(3)} '
        'range=${(maxLuminance - minLuminance).toStringAsFixed(3)} '
        'uniqueSampled=${colors.length} latencyMs=${stopwatch.elapsedMilliseconds}',
      );
    }
  }, skip: !RuntimeModeService.forceGpuRender);
}
