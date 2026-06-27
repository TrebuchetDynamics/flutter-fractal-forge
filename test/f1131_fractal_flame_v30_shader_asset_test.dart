import 'dart:io';

import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1131_fractal_flame_v30_perspective/f1131_fractal_flame_v30_perspective_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F1131 Perspective uses the bundled shared fractal flame shader', () {
    final module = F1131FractalFlameV30Perspective();

    expect(
      module.shader,
      'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag',
    );
    expect(File(module.shader).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shader}'),
    );
    expect(
      File(module.shader).readAsStringSync(),
      contains('if (var_id == 30)'),
    );
  });
}
