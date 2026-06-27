import 'dart:io';

import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1172_orbit_trap_lemniscate/f1172_orbit_trap_lemniscate_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F1172 Lemniscate uses the bundled shared orbit-trap shader', () {
    final module = F1172OrbitTrapLemniscate();

    expect(
      module.shader,
      'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
    );
    expect(File(module.shader).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shader}'),
    );
    expect(File(module.shader).readAsStringSync(), contains('mode == 17'));
  });
}
