// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0757_stern_brocot_tree_fractal/f0757_stern_brocot_tree_fractal_module.dart';

void main() {
  test('F0757SternBrocotTreeFractal instantiates', () {
    final m = F0757SternBrocotTreeFractal();
    expect(m.id, 'f0757_stern_brocot_tree_fractal');
    expect(m.shader, 'shaders/f0757_stern_brocot_tree_fractal_gpu.frag');
  });

  test('F0757SternBrocotTreeFractal presets are well-formed', () {
    final m = F0757SternBrocotTreeFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0757SternBrocotTreeFractal metadata is consistent', () {
    final m = F0757SternBrocotTreeFractal();
    expect(m.metadata.id, m.id);
  });
}
