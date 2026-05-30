// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1130_fractal_flame_v29_cylinder/f1130_fractal_flame_v29_cylinder_module.dart';

void main() {
  test('F1130FractalFlameV29Cylinder instantiates', () {
    final m = F1130FractalFlameV29Cylinder();
    expect(m.id, 'f1130_fractal_flame_v29_cylinder');
    expect(m.shader, 'shaders/f1130_fractal_flame_v29_cylinder_gpu.frag');
  });

  test('F1130FractalFlameV29Cylinder presets are well-formed', () {
    final m = F1130FractalFlameV29Cylinder();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1130FractalFlameV29Cylinder metadata is consistent', () {
    final m = F1130FractalFlameV29Cylinder();
    expect(m.metadata.id, m.id);
  });
}
