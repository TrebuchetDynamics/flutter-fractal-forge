// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0815_quadratic_map_c_2_0/f0815_quadratic_map_c_2_0_module.dart';

void main() {
  test('F0815QuadraticMapC20 instantiates', () {
    final m = F0815QuadraticMapC20();
    expect(m.id, 'f0815_quadratic_map_c_2_0');
    expect(m.shader, 'shaders/f0815_quadratic_map_c_2_0_gpu.frag');
  });

  test('F0815QuadraticMapC20 presets are well-formed', () {
    final m = F0815QuadraticMapC20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0815QuadraticMapC20 metadata is consistent', () {
    final m = F0815QuadraticMapC20();
    expect(m.metadata.id, m.id);
  });
}
