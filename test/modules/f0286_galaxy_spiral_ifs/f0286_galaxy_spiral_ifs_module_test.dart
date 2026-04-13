// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0286_galaxy_spiral_ifs/f0286_galaxy_spiral_ifs_module.dart';

void main() {
  test('F0286GalaxySpiralIfs instantiates', () {
    final m = F0286GalaxySpiralIfs();
    expect(m.id, 'f0286_galaxy_spiral_ifs');
    expect(m.shader, 'shaders/f0286_galaxy_spiral_ifs_gpu.frag');
  });

  test('F0286GalaxySpiralIfs presets are well-formed', () {
    final m = F0286GalaxySpiralIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0286GalaxySpiralIfs metadata is consistent', () {
    final m = F0286GalaxySpiralIfs();
    expect(m.metadata.id, m.id);
  });
}
