// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0291_schottky_circle_ifs/f0291_schottky_circle_ifs_module.dart';

void main() {
  test('F0291SchottkyCircleIfs instantiates', () {
    final m = F0291SchottkyCircleIfs();
    expect(m.id, 'f0291_schottky_circle_ifs');
    expect(m.shader, 'shaders/f0291_schottky_circle_ifs_gpu.frag');
  });

  test('F0291SchottkyCircleIfs presets are well-formed', () {
    final m = F0291SchottkyCircleIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0291SchottkyCircleIfs metadata is consistent', () {
    final m = F0291SchottkyCircleIfs();
    expect(m.metadata.id, m.id);
  });
}
