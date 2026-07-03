import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F1131 Perspective uses the bundled shared fractal flame shader', () {
    final module = ModuleRegistry().byId('f1131_fractal_flame_v30_perspective');

    expect(
      module.shaderAsset,
      'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag',
    );
    expect(File(module.shaderAsset).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shaderAsset}'),
    );
    expect(
      File(module.shaderAsset).readAsStringSync(),
      contains('if (var_id == 30)'),
    );
  });
}
