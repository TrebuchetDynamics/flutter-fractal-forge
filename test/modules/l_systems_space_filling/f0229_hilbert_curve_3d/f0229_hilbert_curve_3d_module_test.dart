// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0229_hilbert_curve_3d/f0229_hilbert_curve_3d_module.dart';

void main() {
  test('F0229HilbertCurve3d instantiates', () {
    final m = F0229HilbertCurve3d();
    expect(m.id, 'f0229_hilbert_curve_3d');
    expect(m.shader, 'shaders/f0229_hilbert_curve_3d_gpu.frag');
  });

  test('F0229HilbertCurve3d presets are well-formed', () {
    final m = F0229HilbertCurve3d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0229HilbertCurve3d metadata is consistent', () {
    final m = F0229HilbertCurve3d();
    expect(m.metadata.id, m.id);
  });
}
