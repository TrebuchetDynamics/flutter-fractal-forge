// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0600_tetrahedral_sierpinski_scaled/f0600_tetrahedral_sierpinski_scaled_module.dart';

void main() {
  test('F0600TetrahedralSierpinskiScaled instantiates', () {
    final m = F0600TetrahedralSierpinskiScaled();
    expect(m.id, 'f0600_tetrahedral_sierpinski_scaled');
    expect(m.shader, 'shaders/f0600_tetrahedral_sierpinski_scaled_gpu.frag');
  });

  test('F0600TetrahedralSierpinskiScaled presets are well-formed', () {
    final m = F0600TetrahedralSierpinskiScaled();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0600TetrahedralSierpinskiScaled metadata is consistent', () {
    final m = F0600TetrahedralSierpinskiScaled();
    expect(m.metadata.id, m.id);
  });
}
