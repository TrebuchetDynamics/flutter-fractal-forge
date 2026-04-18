// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0763_weierstrass_function_a_0_3_b_7/f0763_weierstrass_function_a_0_3_b_7_module.dart';

void main() {
  test('F0763WeierstrassFunctionA03B7 instantiates', () {
    final m = F0763WeierstrassFunctionA03B7();
    expect(m.id, 'f0763_weierstrass_function_a_0_3_b_7');
    expect(m.shader, 'shaders/f0763_weierstrass_function_a_0_3_b_7_gpu.frag');
  });

  test('F0763WeierstrassFunctionA03B7 presets are well-formed', () {
    final m = F0763WeierstrassFunctionA03B7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0763WeierstrassFunctionA03B7 metadata is consistent', () {
    final m = F0763WeierstrassFunctionA03B7();
    expect(m.metadata.id, m.id);
  });
}
