import 'dart:io';

import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0147_san_marco_julia/f0147_san_marco_julia_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F0147 San Marco Julia uses the bundled shared Julia shader', () {
    final module = F0147SanMarcoJulia();

    expect(module.shader, 'shaders/escape_time_family/core/julia_gpu.frag');
    expect(File(module.shader).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shader}'),
    );
  });
}
