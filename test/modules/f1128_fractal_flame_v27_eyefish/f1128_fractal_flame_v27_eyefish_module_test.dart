// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1128_fractal_flame_v27_eyefish/f1128_fractal_flame_v27_eyefish_module.dart';

void main() {
  test('F1128FractalFlameV27Eyefish instantiates', () {
    final m = F1128FractalFlameV27Eyefish();
    expect(m.id, 'f1128_fractal_flame_v27_eyefish');
    expect(m.shader, 'shaders/f1128_fractal_flame_v27_eyefish_gpu.frag');
  });

  test('F1128FractalFlameV27Eyefish presets are well-formed', () {
    final m = F1128FractalFlameV27Eyefish();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1128FractalFlameV27Eyefish metadata is consistent', () {
    final m = F1128FractalFlameV27Eyefish();
    expect(m.metadata.id, m.id);
  });
}
