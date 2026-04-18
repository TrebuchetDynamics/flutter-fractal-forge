// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1139_fractal_flame_v38_ngon/f1139_fractal_flame_v38_ngon_module.dart';

void main() {
  test('F1139FractalFlameV38Ngon instantiates', () {
    final m = F1139FractalFlameV38Ngon();
    expect(m.id, 'f1139_fractal_flame_v38_ngon');
    expect(m.shader, 'shaders/f1139_fractal_flame_v38_ngon_gpu.frag');
  });

  test('F1139FractalFlameV38Ngon presets are well-formed', () {
    final m = F1139FractalFlameV38Ngon();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1139FractalFlameV38Ngon metadata is consistent', () {
    final m = F1139FractalFlameV38Ngon();
    expect(m.metadata.id, m.id);
  });
}
