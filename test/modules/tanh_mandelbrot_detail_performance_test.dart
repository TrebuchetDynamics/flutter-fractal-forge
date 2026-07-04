import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag';

  test(
      'Hyperbolic Tangent Mandelbrot keeps detail while avoiding wasted derivative work',
      () {
    final module = ModuleRegistry().byId('f0493_hyperbolic_tangent_mandelbrot');
    final shader = File(asset).readAsStringSync();

    expect(module.shaderAsset, asset);
    expect(module.defaultPreset.params['variant'], 0);
    expect(shader, contains('const int MAX_ITERS = 240;'));
    expect(shader, contains('if (schemeInt >= 50)'));
    expect(shader, contains('fract(6.0 * trap + orbit'));
    expect(shader, isNot(contains('const int MAX_ITERS = 500;')));
  });
}
