// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1218_m_bius_a_1_i_b_1_c_1_d_1_i/f1218_m_bius_a_1_i_b_1_c_1_d_1_i_module.dart';

void main() {
  test('F1218MBiusA1IB1C1D1I instantiates', () {
    final m = F1218MBiusA1IB1C1D1I();
    expect(m.id, 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i');
    expect(m.shader, 'shaders/f1218_m_bius_a_1_i_b_1_c_1_d_1_i_gpu.frag');
  });

  test('F1218MBiusA1IB1C1D1I presets are well-formed', () {
    final m = F1218MBiusA1IB1C1D1I();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1218MBiusA1IB1C1D1I metadata is consistent', () {
    final m = F1218MBiusA1IB1C1D1I();
    expect(m.metadata.id, m.id);
  });
}
