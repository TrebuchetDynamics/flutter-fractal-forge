// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1123_fractal_flame_v22_fan/f1123_fractal_flame_v22_fan_module.dart';

void main() {
  test('F1123FractalFlameV22Fan instantiates', () {
    final m = F1123FractalFlameV22Fan();
    expect(m.id, 'f1123_fractal_flame_v22_fan');
    expect(m.shader, 'shaders/f1123_fractal_flame_v22_fan_gpu.frag');
  });

  test('F1123FractalFlameV22Fan presets are well-formed', () {
    final m = F1123FractalFlameV22Fan();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1123FractalFlameV22Fan metadata is consistent', () {
    final m = F1123FractalFlameV22Fan();
    expect(m.metadata.id, m.id);
  });
}
