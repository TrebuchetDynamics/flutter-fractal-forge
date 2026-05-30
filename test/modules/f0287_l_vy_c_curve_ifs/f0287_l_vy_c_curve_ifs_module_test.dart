// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0287_l_vy_c_curve_ifs/f0287_l_vy_c_curve_ifs_module.dart';

void main() {
  test('F0287LVyCCurveIfs instantiates', () {
    final m = F0287LVyCCurveIfs();
    expect(m.id, 'f0287_l_vy_c_curve_ifs');
    expect(m.shader, 'shaders/f0287_l_vy_c_curve_ifs_gpu.frag');
  });

  test('F0287LVyCCurveIfs presets are well-formed', () {
    final m = F0287LVyCCurveIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0287LVyCCurveIfs metadata is consistent', () {
    final m = F0287LVyCCurveIfs();
    expect(m.metadata.id, m.id);
  });
}
