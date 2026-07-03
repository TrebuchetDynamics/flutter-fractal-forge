import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/services/rendering/perturb_orbit_texture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Regression test for the core-Julia perturbation flat-render bug: with
/// dz never seeded, every pixel evaluated to the reference orbit and the
/// frame was one flat color. Run:
///   xvfb-run -a flutter test integration_test/rendering/perturb_julia_flat_render_test.dart -d linux
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('julia perturbation renders spatially varying output',
      (tester) async {
    await tester.runAsync(() async {
      final program = await ui.FragmentProgram.fromAsset(
          'shaders/escape_time_family/core/escape_time_perturb_gpu.frag');
      final shader = program.fragmentShader();

      // Palette: 256-px gradient (data-exact via the shared rasterizer).
      final paletteBytes = Uint8List(256 * 4);
      for (var x = 0; x < 256; x++) {
        paletteBytes[x * 4] = x;
        paletteBytes[x * 4 + 1] = 255 - x;
        paletteBytes[x * 4 + 2] = 128;
        paletteBytes[x * 4 + 3] = 255;
      }
      final palette = rasterizePerturbOrbitBytes(paletteBytes, 256);

      // Basilica julia (c = -1) centered on the repelling fixed point
      // (1 - sqrt(5))/2 ~ -0.618 (on the Julia set), zoom 1e8: the
      // neighborhood must contain varied escape counts.
      const centerX = -0.6180339887498949;
      const centerY = 0.0;
      const iterations = 500;
      final orbit = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: -1.0,
        juliaCImag: 0.0,
      );
      final orbitTex = rasterizePerturbOrbitBytes(orbit.bytes, iterations * 2);

      shader.setFloat(0, 0.0); // uTime
      shader.setFloat(1, 256.0); // uResolution.x
      shader.setFloat(2, 256.0); // uResolution.y
      shader.setFloat(3, centerX); // uCenter.x
      shader.setFloat(4, centerY); // uCenter.y
      shader.setFloat(5, 1e8); // uZoom
      shader.setFloat(6, iterations.toDouble()); // uIterations
      shader.setFloat(7, 4.0); // uBailout
      shader.setFloat(8, 0.0); // uTransparentBg
      shader.setFloat(9, 1.0); // uFormula = 1 (the historical julia path)
      shader.setFloat(10, 0.0); // uExtra0
      shader.setFloat(11, 0.0); // uExtra1
      shader.setFloat(12, 1.0); // uExtra2 = julia mode
      shader.setImageSampler(0, palette);
      shader.setImageSampler(1, orbitTex);

      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 256, 256));
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 256, 256),
          ui.Paint()..shader = shader);
      final picture = recorder.endRecording();
      final image = picture.toImageSync(256, 256);
      picture.dispose();

      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final distinct = <int>{};
      for (var i = 0; i < px.length; i += 4) {
        distinct.add((px[i] << 16) | (px[i + 1] << 8) | px[i + 2]);
      }
      image.dispose();
      palette.dispose();
      orbitTex.dispose();

      expect(distinct.length, greaterThan(8),
          reason: 'julia perturbation must not render a flat frame '
              '(got ${distinct.length} distinct colors)');
    });
  });
}