import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('representative shader families compile and paint varied pixels',
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

    expect(catalogModuleCards(), findsWidgets);
    await tester.tap(catalogModuleCards().first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(FractalRenderer), findsOneWidget);

    final rendererContext = tester.element(find.byType(FractalRenderer));
    final controller = Provider.of<FractalController>(
      rendererContext,
      listen: false,
    );

    const representatives = <String>[
      'mandelbrot',
      'fractal_flame',
      'barnsley_fern',
      'zeta_newton',
      'lyapunov',
      'mandelbulb',
      'luminous_fold_lattice',
    ];

    for (final moduleId in representatives) {
      controller.selectModule(controller.registry.byId(moduleId),
          animate: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '$moduleId threw while compiling/painting');

      final boundaryFinder = find.ancestor(
        of: find.byType(FractalRenderer),
        matching: find.byType(RepaintBoundary),
      );
      expect(boundaryFinder, findsWidgets,
          reason: '$moduleId capture boundary');

      final boundaries = boundaryFinder
          .evaluate()
          .map((element) => element.renderObject)
          .whereType<RenderRepaintBoundary>()
          .where((boundary) => boundary.attached && boundary.hasSize)
          .toList();
      expect(boundaries, isNotEmpty, reason: '$moduleId attached boundary');
      boundaries.sort(
        (a, b) => (b.size.width * b.size.height)
            .compareTo(a.size.width * a.size.height),
      );

      final image = await boundaries.first.toImage(pixelRatio: 0.25);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      expect(data, isNotNull, reason: '$moduleId pixel capture');

      final bytes = data!.buffer.asUint8List();
      final colors = <int>{};
      var minLuma = 255;
      var maxLuma = 0;
      for (var offset = 0; offset + 3 < bytes.length; offset += 16) {
        final red = bytes[offset];
        final green = bytes[offset + 1];
        final blue = bytes[offset + 2];
        final alpha = bytes[offset + 3];
        if (alpha == 0) continue;
        colors.add((red << 16) | (green << 8) | blue);
        final luma = (red * 299 + green * 587 + blue * 114) ~/ 1000;
        if (luma < minLuma) minLuma = luma;
        if (luma > maxLuma) maxLuma = luma;
      }

      expect(colors.length, greaterThan(16),
          reason: '$moduleId rendered an effectively flat frame');
      expect(maxLuma - minLuma, greaterThan(8),
          reason: '$moduleId lacks meaningful luminance variation');
    }
  });
}
