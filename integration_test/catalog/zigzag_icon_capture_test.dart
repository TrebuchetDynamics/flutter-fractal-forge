import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture genuine full-resolution Zig-Zag Julia icon candidates',
      (tester) async {
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    SharedPreferences.setMockInitialValues({});
    await PaletteService.create();
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    controller.selectModule(
      registry.byId('f0186_zig_zag_julia'),
      animate: false,
    );
    final out = Directory('build/test_output/zigzag-icon/raw')
      ..createSync(recursive: true);
    const size = 2048.0;
    for (final candidate in const [
      (name: 'siegel', real: -0.391, imag: -0.587, zoom: 0.65),
      (name: 'twin', real: -0.74543, imag: 0.11301, zoom: 0.35),
      (name: 'classic', real: -0.8, imag: 0.156, zoom: 0.35),
    ]) {
      controller.updateParam('colorScheme', 0);
      controller.updateParam('juliaCReal', candidate.real);
      controller.updateParam('juliaCImag', candidate.imag);
      controller.updateView(controller.view.copyWith(zoom: candidate.zoom));
      final key = GlobalKey();
      final sink = FractalRenderSnapshotSink();
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider.value(
          value: controller,
          // Capture the real 2048px layer, never upscale a window-sized render.
          child: Center(
              child: OverflowBox(
            minWidth: size,
            maxWidth: size,
            minHeight: size,
            maxHeight: size,
            child: RepaintBoundary(
              key: key,
              child: SizedBox.square(
                dimension: size,
                child: FractalRenderer(
                  gesturesEnabled: false,
                  animationEnabled: false,
                  showRendererIndicator: false,
                  renderSnapshotSink: sink,
                ),
              ),
            ),
          )),
        ),
      ));
      for (var frame = 0; frame < 30 && sink.snapshot == null; frame++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Shader Error'), findsNothing);
      expect(sink.snapshot, isNotNull,
          reason: 'Require a real renderer frame.');
      final snapshot = sink.snapshot!;
      expect(snapshot.module.id, 'f0186_zig_zag_julia');
      expect(snapshot.time, 0);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      expect(boundary.size, const Size(size, size));
      final image = await boundary.toImage(pixelRatio: 1);
      expect(image.width, 2048);
      expect(image.height, 2048);
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      image.dispose();
      final stem = 'zigzag-revised-${candidate.name}';
      File('${out.path}/$stem.png').writeAsBytesSync(png.buffer.asUint8List());
      final v = snapshot.state.view;
      final metadata = const JsonEncoder.withIndent('  ').convert({
        'moduleId': snapshot.module.id,
        'shaderAsset': snapshot.module.shaderAsset,
        'params': snapshot.state.params,
        'view': {
          'panX': v.pan.x,
          'panY': v.pan.y,
          'zoom': v.zoom,
          'rotX': v.rotation.x,
          'rotY': v.rotation.y,
          'rotZ': v.rotation.z
        },
        'time': snapshot.time,
        'animationEnabled': false,
        'transparentBackground': snapshot.state.transparentBackground,
        'glowEnabled': snapshot.glowEnabled,
        'glowSigma': snapshot.glowSigma,
        'glowIntensity': snapshot.glowIntensity,
        'kaleidoscopeEnabled': snapshot.kaleidoscopeEnabled,
        'kaleidoscopeSectors': snapshot.kaleidoscopeSectors,
        'kaleidoscopeMirror': snapshot.kaleidoscopeMirror,
        'kaleidoscopeRotation': snapshot.kaleidoscopeRotation,
        'kaleidoscopeMirrorMode': snapshot.kaleidoscopeMirrorMode,
        'fluidModeEnabled': controller.fluidModeEnabled,
        'width': 2048,
        'height': 2048,
        'capture': 'FractalRenderer RepaintBoundary.toImage(pixelRatio: 1)',
      });
      File('${out.path}/$stem.json').writeAsStringSync('$metadata\n');
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
