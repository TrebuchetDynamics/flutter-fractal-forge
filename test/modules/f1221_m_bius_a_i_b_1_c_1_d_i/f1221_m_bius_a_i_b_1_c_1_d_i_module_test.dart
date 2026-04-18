// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1221_m_bius_a_i_b_1_c_1_d_i/f1221_m_bius_a_i_b_1_c_1_d_i_module.dart';

void main() {
  test('F1221MBiusAIB1C1DI instantiates', () {
    final m = F1221MBiusAIB1C1DI();
    expect(m.id, 'f1221_m_bius_a_i_b_1_c_1_d_i');
    expect(m.shader, 'shaders/f1221_m_bius_a_i_b_1_c_1_d_i_gpu.frag');
  });

  test('F1221MBiusAIB1C1DI presets are well-formed', () {
    final m = F1221MBiusAIB1C1DI();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1221MBiusAIB1C1DI metadata is consistent', () {
    final m = F1221MBiusAIB1C1DI();
    expect(m.metadata.id, m.id);
  });
}
