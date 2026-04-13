// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0239_sierpinski_triangle_l_system/f0239_sierpinski_triangle_l_system_module.dart';

void main() {
  test('F0239SierpinskiTriangleLSystem instantiates', () {
    final m = F0239SierpinskiTriangleLSystem();
    expect(m.id, 'f0239_sierpinski_triangle_l_system');
    expect(m.shader, 'shaders/f0239_sierpinski_triangle_l_system_gpu.frag');
  });

  test('F0239SierpinskiTriangleLSystem presets are well-formed', () {
    final m = F0239SierpinskiTriangleLSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0239SierpinskiTriangleLSystem metadata is consistent', () {
    final m = F0239SierpinskiTriangleLSystem();
    expect(m.metadata.id, m.id);
  });
}
