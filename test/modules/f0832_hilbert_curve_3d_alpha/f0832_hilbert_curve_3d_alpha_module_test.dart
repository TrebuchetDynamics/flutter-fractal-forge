// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0832_hilbert_curve_3d_alpha/f0832_hilbert_curve_3d_alpha_module.dart';

void main() {
  test('F0832HilbertCurve3dAlpha instantiates', () {
    final m = F0832HilbertCurve3dAlpha();
    expect(m.id, 'f0832_hilbert_curve_3d_alpha');
    expect(m.shader, 'shaders/f0832_hilbert_curve_3d_alpha_gpu.frag');
  });

  test('F0832HilbertCurve3dAlpha presets are well-formed', () {
    final m = F0832HilbertCurve3dAlpha();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0832HilbertCurve3dAlpha metadata is consistent', () {
    final m = F0832HilbertCurve3dAlpha();
    expect(m.metadata.id, m.id);
  });
}
