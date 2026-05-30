// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0795_euler_totient_fractal/f0795_euler_totient_fractal_module.dart';

void main() {
  test('F0795EulerTotientFractal instantiates', () {
    final m = F0795EulerTotientFractal();
    expect(m.id, 'f0795_euler_totient_fractal');
    expect(m.shader, 'shaders/f0795_euler_totient_fractal_gpu.frag');
  });

  test('F0795EulerTotientFractal presets are well-formed', () {
    final m = F0795EulerTotientFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0795EulerTotientFractal metadata is consistent', () {
    final m = F0795EulerTotientFractal();
    expect(m.metadata.id, m.id);
  });
}
