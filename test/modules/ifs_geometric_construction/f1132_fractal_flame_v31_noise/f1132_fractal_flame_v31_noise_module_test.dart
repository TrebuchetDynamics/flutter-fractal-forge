// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1132_fractal_flame_v31_noise/f1132_fractal_flame_v31_noise_module.dart';

void main() {
  test('F1132FractalFlameV31Noise instantiates', () {
    final m = F1132FractalFlameV31Noise();
    expect(m.id, 'f1132_fractal_flame_v31_noise');
    expect(m.shader, 'shaders/f1132_fractal_flame_v31_noise_gpu.frag');
  });

  test('F1132FractalFlameV31Noise presets are well-formed', () {
    final m = F1132FractalFlameV31Noise();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1132FractalFlameV31Noise metadata is consistent', () {
    final m = F1132FractalFlameV31Noise();
    expect(m.metadata.id, m.id);
  });
}
