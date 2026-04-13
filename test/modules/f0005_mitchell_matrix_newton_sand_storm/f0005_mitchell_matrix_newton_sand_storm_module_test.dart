// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f0005_mitchell_matrix_newton_sand_storm/f0005_mitchell_matrix_newton_sand_storm_module.dart';

void main() {
  test('F0005MitchellMatrixNewtonSandStorm instantiates', () {
    final m = F0005MitchellMatrixNewtonSandStorm();
    expect(m.id, 'f0005_mitchell_matrix_newton_sand_storm');
    expect(m.shader, 'shaders/f0005_mitchell_matrix_newton_sand_storm_gpu.frag');
  });

  test('F0005MitchellMatrixNewtonSandStorm presets are well-formed', () {
    final m = F0005MitchellMatrixNewtonSandStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0005MitchellMatrixNewtonSandStorm metadata is consistent', () {
    final m = F0005MitchellMatrixNewtonSandStorm();
    expect(m.metadata.id, m.id);
  });
}
