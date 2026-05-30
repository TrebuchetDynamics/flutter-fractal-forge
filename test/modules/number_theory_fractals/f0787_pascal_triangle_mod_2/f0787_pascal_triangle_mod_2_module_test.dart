// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0787_pascal_triangle_mod_2/f0787_pascal_triangle_mod_2_module.dart';

void main() {
  test('F0787PascalTriangleMod2 instantiates', () {
    final m = F0787PascalTriangleMod2();
    expect(m.id, 'f0787_pascal_triangle_mod_2');
    expect(m.shader, 'shaders/f0787_pascal_triangle_mod_2_gpu.frag');
  });

  test('F0787PascalTriangleMod2 presets are well-formed', () {
    final m = F0787PascalTriangleMod2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0787PascalTriangleMod2 metadata is consistent', () {
    final m = F0787PascalTriangleMod2();
    expect(m.metadata.id, m.id);
  });
}
