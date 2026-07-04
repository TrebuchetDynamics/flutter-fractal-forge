import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('log(z²)+c avoids the singular z0=0 start that flattens detail', () {
    final module = ModuleRegistry().byId('f0501_log_z_c');
    final shader = File(module.shaderAsset).readAsStringSync();

    expect(module.shaderAsset, contains('sine_mandelbrot_gpu.frag'));
    expect(module.defaultPreset.params['variant'], 11);
    expect(shader, contains('variant == 9 || variant == 11'));
    expect(shader, isNot(contains('vec2 z = (variant == 9) ? c : vec2(0.0);')));
  });
}
