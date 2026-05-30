// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1109_fractal_flame_v8_disc/f1109_fractal_flame_v8_disc_module.dart';

void main() {
  test('F1109FractalFlameV8Disc instantiates', () {
    final m = F1109FractalFlameV8Disc();
    expect(m.id, 'f1109_fractal_flame_v8_disc');
    expect(m.shader, 'shaders/f1109_fractal_flame_v8_disc_gpu.frag');
  });

  test('F1109FractalFlameV8Disc presets are well-formed', () {
    final m = F1109FractalFlameV8Disc();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1109FractalFlameV8Disc metadata is consistent', () {
    final m = F1109FractalFlameV8Disc();
    expect(m.metadata.id, m.id);
  });
}
