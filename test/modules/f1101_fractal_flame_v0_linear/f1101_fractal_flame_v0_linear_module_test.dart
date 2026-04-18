// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1101_fractal_flame_v0_linear/f1101_fractal_flame_v0_linear_module.dart';

void main() {
  test('F1101FractalFlameV0Linear instantiates', () {
    final m = F1101FractalFlameV0Linear();
    expect(m.id, 'f1101_fractal_flame_v0_linear');
    expect(m.shader, 'shaders/f1101_fractal_flame_v0_linear_gpu.frag');
  });

  test('F1101FractalFlameV0Linear presets are well-formed', () {
    final m = F1101FractalFlameV0Linear();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1101FractalFlameV0Linear metadata is consistent', () {
    final m = F1101FractalFlameV0Linear();
    expect(m.metadata.id, m.id);
  });
}
