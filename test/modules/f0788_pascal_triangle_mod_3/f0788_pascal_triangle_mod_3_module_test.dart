// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0788_pascal_triangle_mod_3/f0788_pascal_triangle_mod_3_module.dart';

void main() {
  test('F0788PascalTriangleMod3 instantiates', () {
    final m = F0788PascalTriangleMod3();
    expect(m.id, 'f0788_pascal_triangle_mod_3');
    expect(m.shader, 'shaders/f0788_pascal_triangle_mod_3_gpu.frag');
  });

  test('F0788PascalTriangleMod3 presets are well-formed', () {
    final m = F0788PascalTriangleMod3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0788PascalTriangleMod3 metadata is consistent', () {
    final m = F0788PascalTriangleMod3();
    expect(m.metadata.id, m.id);
  });
}
