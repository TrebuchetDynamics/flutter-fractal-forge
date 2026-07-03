import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F1172 Lemniscate uses the bundled shared orbit-trap shader', () {
    final module = ModuleRegistry().byId('f1172_orbit_trap_lemniscate');

    expect(
      module.shaderAsset,
      'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
    );
    expect(File(module.shaderAsset).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shaderAsset}'),
    );
    expect(File(module.shaderAsset).readAsStringSync(), contains('mode == 17'));
  });
}
