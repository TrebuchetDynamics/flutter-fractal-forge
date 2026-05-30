// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1113_fractal_flame_v12_ex/f1113_fractal_flame_v12_ex_module.dart';

void main() {
  test('F1113FractalFlameV12Ex instantiates', () {
    final m = F1113FractalFlameV12Ex();
    expect(m.id, 'f1113_fractal_flame_v12_ex');
    expect(m.shader, 'shaders/f1113_fractal_flame_v12_ex_gpu.frag');
  });

  test('F1113FractalFlameV12Ex presets are well-formed', () {
    final m = F1113FractalFlameV12Ex();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1113FractalFlameV12Ex metadata is consistent', () {
    final m = F1113FractalFlameV12Ex();
    expect(m.metadata.id, m.id);
  });
}
