import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/actions/breathing_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'breathing changes Julia pixels and Pause preserves the rendered shape',
      (tester) async {
    final registry = ModuleRegistry();
    final module = registry.byId('julia');
    final controller = FractalController(registry)
      ..selectModule(module, animate: false);
    final breathing =
        BreathingController(controller: controller, canAnimate: () => true);
    try {
      final program = (await tester
          .runAsync(() => ui.FragmentProgram.fromAsset(module.shaderAsset)))!;
      Future<Uint8List> render() async {
        final shader = program.fragmentShader();
        final size = const ui.Size(64, 64);
        module.setUniforms(
            shader,
            FractalRenderState(
              params: controller.params,
              view: controller.view,
              transparentBackground: false,
            ),
            size,
            0);
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder)
            .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        try {
          final bytes =
              (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
          return Uint8List.fromList(bytes.buffer
              .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        } finally {
          image.dispose();
          picture.dispose();
          shader.dispose();
        }
      }

      final before = (await tester.runAsync(render))!;
      breathing.play();
      await tester.pump(const Duration(seconds: 2));
      breathing.pause();
      final after = (await tester.runAsync(render))!;
      var changedPixels = 0;
      for (var offset = 0; offset < before.length; offset += 4) {
        final delta = (before[offset] - after[offset]).abs() +
            (before[offset + 1] - after[offset + 1]).abs() +
            (before[offset + 2] - after[offset + 2]).abs();
        if (delta > 12) changedPixels++;
        expect(after[offset + 3], 255);
      }
      expect(changedPixels, greaterThan(100),
          reason:
              'Parameter playback must visibly change the shader output, not only sliders.');
      await tester.pump(const Duration(seconds: 2));
      expect((await tester.runAsync(render))!, after);
    } finally {
      breathing.dispose();
      controller.dispose();
    }
  });
}
