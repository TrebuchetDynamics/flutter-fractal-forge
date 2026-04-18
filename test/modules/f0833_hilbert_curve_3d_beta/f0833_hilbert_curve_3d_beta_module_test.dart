// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0833_hilbert_curve_3d_beta/f0833_hilbert_curve_3d_beta_module.dart';

void main() {
  test('F0833HilbertCurve3dBeta instantiates', () {
    final m = F0833HilbertCurve3dBeta();
    expect(m.id, 'f0833_hilbert_curve_3d_beta');
    expect(m.shader, 'shaders/f0833_hilbert_curve_3d_beta_gpu.frag');
  });

  test('F0833HilbertCurve3dBeta presets are well-formed', () {
    final m = F0833HilbertCurve3dBeta();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0833HilbertCurve3dBeta metadata is consistent', () {
    final m = F0833HilbertCurve3dBeta();
    expect(m.metadata.id, m.id);
  });
}
