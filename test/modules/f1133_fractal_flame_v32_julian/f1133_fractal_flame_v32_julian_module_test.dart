// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1133_fractal_flame_v32_julian/f1133_fractal_flame_v32_julian_module.dart';

void main() {
  test('F1133FractalFlameV32Julian instantiates', () {
    final m = F1133FractalFlameV32Julian();
    expect(m.id, 'f1133_fractal_flame_v32_julian');
    expect(m.shader, 'shaders/f1133_fractal_flame_v32_julian_gpu.frag');
  });

  test('F1133FractalFlameV32Julian presets are well-formed', () {
    final m = F1133FractalFlameV32Julian();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1133FractalFlameV32Julian metadata is consistent', () {
    final m = F1133FractalFlameV32Julian();
    expect(m.metadata.id, m.id);
  });
}
