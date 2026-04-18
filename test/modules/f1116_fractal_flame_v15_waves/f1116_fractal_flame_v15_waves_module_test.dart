// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1116_fractal_flame_v15_waves/f1116_fractal_flame_v15_waves_module.dart';

void main() {
  test('F1116FractalFlameV15Waves instantiates', () {
    final m = F1116FractalFlameV15Waves();
    expect(m.id, 'f1116_fractal_flame_v15_waves');
    expect(m.shader, 'shaders/f1116_fractal_flame_v15_waves_gpu.frag');
  });

  test('F1116FractalFlameV15Waves presets are well-formed', () {
    final m = F1116FractalFlameV15Waves();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1116FractalFlameV15Waves metadata is consistent', () {
    final m = F1116FractalFlameV15Waves();
    expect(m.metadata.id, m.id);
  });
}
