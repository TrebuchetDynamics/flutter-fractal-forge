// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1119_fractal_flame_v18_exponential/f1119_fractal_flame_v18_exponential_module.dart';

void main() {
  test('F1119FractalFlameV18Exponential instantiates', () {
    final m = F1119FractalFlameV18Exponential();
    expect(m.id, 'f1119_fractal_flame_v18_exponential');
    expect(m.shader, 'shaders/f1119_fractal_flame_v18_exponential_gpu.frag');
  });

  test('F1119FractalFlameV18Exponential presets are well-formed', () {
    final m = F1119FractalFlameV18Exponential();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1119FractalFlameV18Exponential metadata is consistent', () {
    final m = F1119FractalFlameV18Exponential();
    expect(m.metadata.id, m.id);
  });
}
