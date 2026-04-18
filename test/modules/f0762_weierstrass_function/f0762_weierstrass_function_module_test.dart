// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0762_weierstrass_function/f0762_weierstrass_function_module.dart';

void main() {
  test('F0762WeierstrassFunction instantiates', () {
    final m = F0762WeierstrassFunction();
    expect(m.id, 'f0762_weierstrass_function');
    expect(m.shader, 'shaders/f0762_weierstrass_function_gpu.frag');
  });

  test('F0762WeierstrassFunction presets are well-formed', () {
    final m = F0762WeierstrassFunction();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0762WeierstrassFunction metadata is consistent', () {
    final m = F0762WeierstrassFunction();
    expect(m.metadata.id, m.id);
  });
}
