// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0595_sierpinski_octahedron_3d/f0595_sierpinski_octahedron_3d_module.dart';

void main() {
  test('F0595SierpinskiOctahedron3d instantiates', () {
    final m = F0595SierpinskiOctahedron3d();
    expect(m.id, 'f0595_sierpinski_octahedron_3d');
    expect(m.shader, 'shaders/f0595_sierpinski_octahedron_3d_gpu.frag');
  });

  test('F0595SierpinskiOctahedron3d presets are well-formed', () {
    final m = F0595SierpinskiOctahedron3d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0595SierpinskiOctahedron3d metadata is consistent', () {
    final m = F0595SierpinskiOctahedron3d();
    expect(m.metadata.id, m.id);
  });
}
