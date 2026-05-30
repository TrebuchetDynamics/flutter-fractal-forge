// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0834_hilbert_curve_3d_gosper/f0834_hilbert_curve_3d_gosper_module.dart';

void main() {
  test('F0834HilbertCurve3dGosper instantiates', () {
    final m = F0834HilbertCurve3dGosper();
    expect(m.id, 'f0834_hilbert_curve_3d_gosper');
    expect(m.shader, 'shaders/f0834_hilbert_curve_3d_gosper_gpu.frag');
  });

  test('F0834HilbertCurve3dGosper presets are well-formed', () {
    final m = F0834HilbertCurve3dGosper();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0834HilbertCurve3dGosper metadata is consistent', () {
    final m = F0834HilbertCurve3dGosper();
    expect(m.metadata.id, m.id);
  });
}
