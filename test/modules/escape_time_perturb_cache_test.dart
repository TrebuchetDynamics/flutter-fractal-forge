import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('perturbation reuses only the exact center and Julia constant',
      () async {
    final julia = ModuleRegistry().byId('julia');
    final module = buildEscapeTimePerturbModule(julia);
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    addTearDown(shader.dispose);

    const iterations = 16;
    var orbitTexturesCreated = 0;
    final previousOnCreate = ui.Image.onCreate;
    addTearDown(() => ui.Image.onCreate = previousOnCreate);
    ui.Image.onCreate = (image) {
      previousOnCreate?.call(image);
      // The orbit sampler has two texels per iteration; the palette does not.
      if (image.width == iterations * 2 && image.height == 1) {
        orbitTexturesCreated++;
      }
    };

    const delta = 1e-14;
    const x = -0.5, y = 0.25, cReal = -0.8, cImag = 0.156;
    final frames = [
      (x, y, cReal, cImag),
      (x + delta, y, cReal, cImag),
      (x + delta, y + delta, cReal, cImag),
      (x + delta, y + delta, cReal + delta, cImag),
      (x + delta, y + delta, cReal + delta, cImag + delta),
    ];
    for (final (index, (panX, panY, seedX, seedY)) in frames.indexed) {
      final state = FractalRenderState(
        view: julia.defaultPreset.view.copyWith(
          pan: Vector2(panX, panY),
          zoom: 1e11,
        ),
        params: {
          'iterations': iterations,
          'juliaCReal': seedX,
          'juliaCImag': seedY
        },
        transparentBackground: false,
      );
      const size = ui.Size(1920, 1080);
      module.setUniforms(shader, state, size, 0);
      expect(orbitTexturesCreated, index + 1,
          reason: 'frame $index must compute an orbit for its changed input');
      module.setUniforms(shader, state, size, 1);
      expect(orbitTexturesCreated, index + 1,
          reason: 'redrawing frame $index must reuse its reference orbit');
    }
  });
}
