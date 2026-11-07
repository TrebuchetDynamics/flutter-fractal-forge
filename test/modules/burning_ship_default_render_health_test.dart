import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registered Burning Ship default has opaque visible structure',
      () async {
    final module = ModuleRegistry().byId('burning_ship');
    final image = await _render(
      module,
      FractalRenderState(
        transparentBackground: false,
        params: module.defaultPreset.params,
        view: module.defaultPreset.view,
      ),
      256,
    );
    final metrics = RenderAuditMetrics.fromImage(image, expectedSize: 256);
    debugPrint('[burning-ship-default] ${metrics.toJson()}');
    expect(image.every((pixel) => pixel.a == 255), isTrue);
    expect(metrics.verdict, 'pass');
  });

  test('registered powers preserve classification and abs-gated normal shading',
      () async {
    final module = ModuleRegistry().byId('burning_ship');
    // Independent scalar-complex samples: 40 steps, radius 4, z0 = 0.
    // RGB uses palette 0 and its abs-gated derivative under light angle 0.
    // Include the public p=1 lower bound (derivative exponent 0), not only p=2.
    for (final (power, cx, cy, palette, normal) in [
      (1.0, 0.6, 0.4, [242, 2, 215], [235, 2, 209]),
      (1.5, 0.6, 0.4, [247, 7, 205], [244, 7, 203]),
      (2.0, 0.6, 0.4, [248, 11, 203], [247, 11, 203]),
      (2.5, 0.6, 0.4, [243, 0, 213], [242, 0, 212]),
      (3.0, 1.5, 0.5, [253, 50, 184], [252, 50, 183]),
    ]) {
      for (final scheme in [0, 50]) {
        for (final (x, y, escaped) in [
          (0.0, 0.0, false),
          (-0.2, -0.1, false),
          (-0.8, -0.6, power > 2),
          (cx, cy, true),
        ]) {
          final image = await _render(
            module,
            FractalRenderState(
              // Alpha classifies the orbit independently of palette/lighting.
              transparentBackground: true,
              params: {
                ...module.defaultPreset.params,
                'iterations': 40,
                'bailout': 4.0,
                'power': power,
                'colorScheme': scheme,
              },
              view: FractalViewState(
                pan: Vector2(x, -y),
                zoom: 1,
                rotation: Vector3.zero(),
              ),
            ),
            1,
          );
          final pixel = image.getPixel(0, 0);
          final label = 'p=$power c=($x,$y) scheme=$scheme';
          expect(pixel.a, escaped ? 255 : 0, reason: label);
          if (x == cx && y == cy) {
            final expected = scheme == 0 ? palette : normal;
            final actual = [pixel.r, pixel.g, pixel.b];
            for (var channel = 0; channel < 3; channel++) {
              expect(actual[channel], closeTo(expected[channel], 2),
                  reason: label);
            }
          }
        }
      }
    }
  });
}

Future<img.Image> _render(
    FractalModule module, FractalRenderState state, int size) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  ui.Picture? picture;
  ui.Image? frame;
  try {
    module.setUniforms(shader, state, ui.Size.square(size.toDouble()), 0);
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..shader = shader,
    );
    picture = recorder.endRecording();
    frame = await picture.toImage(size, size);
    final bytes = (await frame.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    expect(bytes.lengthInBytes, size * size * 4);
    return img.Image.fromBytes(
        width: size,
        height: size,
        bytes: bytes.buffer,
        bytesOffset: bytes.offsetInBytes,
        numChannels: 4);
  } finally {
    frame?.dispose();
    picture?.dispose();
    shader.dispose();
  }
}
