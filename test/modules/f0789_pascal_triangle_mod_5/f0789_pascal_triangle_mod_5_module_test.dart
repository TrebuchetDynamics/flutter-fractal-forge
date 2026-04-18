// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0789_pascal_triangle_mod_5/f0789_pascal_triangle_mod_5_module.dart';

void main() {
  test('F0789PascalTriangleMod5 instantiates', () {
    final m = F0789PascalTriangleMod5();
    expect(m.id, 'f0789_pascal_triangle_mod_5');
    expect(m.shader, 'shaders/f0789_pascal_triangle_mod_5_gpu.frag');
  });

  test('F0789PascalTriangleMod5 presets are well-formed', () {
    final m = F0789PascalTriangleMod5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0789PascalTriangleMod5 metadata is consistent', () {
    final m = F0789PascalTriangleMod5();
    expect(m.metadata.id, m.id);
  });
}
