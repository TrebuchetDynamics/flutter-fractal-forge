// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0294_fractal_flame_sinusoidal/f0294_fractal_flame_sinusoidal_module.dart';

void main() {
  test('F0294FractalFlameSinusoidal instantiates', () {
    final m = F0294FractalFlameSinusoidal();
    expect(m.id, 'f0294_fractal_flame_sinusoidal');
    expect(m.shader, 'shaders/f0294_fractal_flame_sinusoidal_gpu.frag');
  });

  test('F0294FractalFlameSinusoidal presets are well-formed', () {
    final m = F0294FractalFlameSinusoidal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0294FractalFlameSinusoidal metadata is consistent', () {
    final m = F0294FractalFlameSinusoidal();
    expect(m.metadata.id, m.id);
  });
}
