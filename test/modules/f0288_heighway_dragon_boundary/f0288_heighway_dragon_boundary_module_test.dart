// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0288_heighway_dragon_boundary/f0288_heighway_dragon_boundary_module.dart';

void main() {
  test('F0288HeighwayDragonBoundary instantiates', () {
    final m = F0288HeighwayDragonBoundary();
    expect(m.id, 'f0288_heighway_dragon_boundary');
    expect(m.shader, 'shaders/f0288_heighway_dragon_boundary_gpu.frag');
  });

  test('F0288HeighwayDragonBoundary presets are well-formed', () {
    final m = F0288HeighwayDragonBoundary();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0288HeighwayDragonBoundary metadata is consistent', () {
    final m = F0288HeighwayDragonBoundary();
    expect(m.metadata.id, m.id);
  });
}
