// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1111_fractal_flame_v10_hyperbolic/f1111_fractal_flame_v10_hyperbolic_module.dart';

void main() {
  test('F1111FractalFlameV10Hyperbolic instantiates', () {
    final m = F1111FractalFlameV10Hyperbolic();
    expect(m.id, 'f1111_fractal_flame_v10_hyperbolic');
    expect(m.shader, 'shaders/f1111_fractal_flame_v10_hyperbolic_gpu.frag');
  });

  test('F1111FractalFlameV10Hyperbolic presets are well-formed', () {
    final m = F1111FractalFlameV10Hyperbolic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1111FractalFlameV10Hyperbolic metadata is consistent', () {
    final m = F1111FractalFlameV10Hyperbolic();
    expect(m.metadata.id, m.id);
  });
}
