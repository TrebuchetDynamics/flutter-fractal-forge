// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0814_quadratic_map_c_1_4/f0814_quadratic_map_c_1_4_module.dart';

void main() {
  test('F0814QuadraticMapC14 instantiates', () {
    final m = F0814QuadraticMapC14();
    expect(m.id, 'f0814_quadratic_map_c_1_4');
    expect(m.shader, 'shaders/f0814_quadratic_map_c_1_4_gpu.frag');
  });

  test('F0814QuadraticMapC14 presets are well-formed', () {
    final m = F0814QuadraticMapC14();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0814QuadraticMapC14 metadata is consistent', () {
    final m = F0814QuadraticMapC14();
    expect(m.metadata.id, m.id);
  });
}
