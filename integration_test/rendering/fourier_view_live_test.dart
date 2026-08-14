import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_spectrum_view.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('viewer toggles a live nonblank Fourier spectrum',
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
    final rendererContext = tester.element(find.byType(FractalRenderer));
    final controller =
        Provider.of<FractalController>(rendererContext, listen: false);
    controller.selectModule(
      controller.registry.byId('mandelbrot'),
      animate: false,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await _openMore(tester);
    final fourier = find.byKey(const ValueKey('viewerFourierButton'));
    await tester.scrollUntilVisible(
      fourier,
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(fourier);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FourierSpectrumView), findsOneWidget);
    expect(find.text('Rendered spatial base field'), findsOneWidget);
    expect(find.text('Sampled Fourier magnitude'), findsOneWidget);

    for (var attempt = 0;
        attempt < 12 &&
            find
                .byKey(const ValueKey('fourierSpectrumImage'))
                .evaluate()
                .isEmpty;
        attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    final spectrum = find.byKey(const ValueKey('fourierSpectrumImage'));
    expect(spectrum, findsOneWidget);
    expect(find.byType(FourierSpectrumView), findsOneWidget);
    final spectrumSize = tester.getSize(find.byType(FourierSpectrumView));
    final screenSize =
        tester.getSize(find.byKey(const Key('fractalViewerRoot')));
    expect(spectrumSize.height, lessThan(screenSize.height * 0.60));
    expect(spectrumSize.height, greaterThan(screenSize.height * 0.40));

    final raw = tester.widget<RawImage>(spectrum);
    final image = raw.image!;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(data, isNotNull);
    final bytes = data!.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    var minimum = 765;
    var maximum = 0;
    final unique = <int>{};
    for (var offset = 0; offset < bytes.length; offset += 4) {
      final value = bytes[offset] + bytes[offset + 1] + bytes[offset + 2];
      minimum = value < minimum ? value : minimum;
      maximum = value > maximum ? value : maximum;
      unique.add(value);
    }
    // The normalized colormap must contain measured contrast; a static loading
    // image or fabricated one-color fallback fails this gate.
    expect(maximum - minimum, greaterThan(100));
    expect(unique.length, greaterThan(8));

    await _openMore(tester);
    await tester.scrollUntilVisible(
      fourier,
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(fourier);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(FourierSpectrumView), findsNothing);
  }, skip: !RuntimeModeService.forceGpuRender);
}

Future<void> _openMore(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('viewerMoreActionsButton')));
  await tester.pump(const Duration(milliseconds: 400));
}
