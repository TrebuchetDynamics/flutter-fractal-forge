// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0596_cube_fractal_jerusalem/f0596_cube_fractal_jerusalem_module.dart';

void main() {
  test('F0596CubeFractalJerusalem instantiates', () {
    final m = F0596CubeFractalJerusalem();
    expect(m.id, 'f0596_cube_fractal_jerusalem');
    expect(m.shader, 'shaders/f0596_cube_fractal_jerusalem_gpu.frag');
  });

  test('F0596CubeFractalJerusalem presets are well-formed', () {
    final m = F0596CubeFractalJerusalem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0596CubeFractalJerusalem metadata is consistent', () {
    final m = F0596CubeFractalJerusalem();
    expect(m.metadata.id, m.id);
  });
}
