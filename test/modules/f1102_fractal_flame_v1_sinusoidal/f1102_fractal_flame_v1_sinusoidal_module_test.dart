// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1102_fractal_flame_v1_sinusoidal/f1102_fractal_flame_v1_sinusoidal_module.dart';

void main() {
  test('F1102FractalFlameV1Sinusoidal instantiates', () {
    final m = F1102FractalFlameV1Sinusoidal();
    expect(m.id, 'f1102_fractal_flame_v1_sinusoidal');
    expect(m.shader, 'shaders/f1102_fractal_flame_v1_sinusoidal_gpu.frag');
  });

  test('F1102FractalFlameV1Sinusoidal presets are well-formed', () {
    final m = F1102FractalFlameV1Sinusoidal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1102FractalFlameV1Sinusoidal metadata is consistent', () {
    final m = F1102FractalFlameV1Sinusoidal();
    expect(m.metadata.id, m.id);
  });
}
