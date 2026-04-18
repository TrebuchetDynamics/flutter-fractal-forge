// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0816_gauss_iteration_map/f0816_gauss_iteration_map_module.dart';

void main() {
  test('F0816GaussIterationMap instantiates', () {
    final m = F0816GaussIterationMap();
    expect(m.id, 'f0816_gauss_iteration_map');
    expect(m.shader, 'shaders/f0816_gauss_iteration_map_gpu.frag');
  });

  test('F0816GaussIterationMap presets are well-formed', () {
    final m = F0816GaussIterationMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0816GaussIterationMap metadata is consistent', () {
    final m = F0816GaussIterationMap();
    expect(m.metadata.id, m.id);
  });
}
