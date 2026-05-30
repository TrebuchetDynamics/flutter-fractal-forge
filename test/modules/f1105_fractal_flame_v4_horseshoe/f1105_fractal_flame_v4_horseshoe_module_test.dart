// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1105_fractal_flame_v4_horseshoe/f1105_fractal_flame_v4_horseshoe_module.dart';

void main() {
  test('F1105FractalFlameV4Horseshoe instantiates', () {
    final m = F1105FractalFlameV4Horseshoe();
    expect(m.id, 'f1105_fractal_flame_v4_horseshoe');
    expect(m.shader, 'shaders/f1105_fractal_flame_v4_horseshoe_gpu.frag');
  });

  test('F1105FractalFlameV4Horseshoe presets are well-formed', () {
    final m = F1105FractalFlameV4Horseshoe();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1105FractalFlameV4Horseshoe metadata is consistent', () {
    final m = F1105FractalFlameV4Horseshoe();
    expect(m.metadata.id, m.id);
  });
}
