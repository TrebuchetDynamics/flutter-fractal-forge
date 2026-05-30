// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1219_m_bius_a_2_b_1_c_1_d_2/f1219_m_bius_a_2_b_1_c_1_d_2_module.dart';

void main() {
  test('F1219MBiusA2B1C1D2 instantiates', () {
    final m = F1219MBiusA2B1C1D2();
    expect(m.id, 'f1219_m_bius_a_2_b_1_c_1_d_2');
    expect(m.shader, 'shaders/f1219_m_bius_a_2_b_1_c_1_d_2_gpu.frag');
  });

  test('F1219MBiusA2B1C1D2 presets are well-formed', () {
    final m = F1219MBiusA2B1C1D2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1219MBiusA2B1C1D2 metadata is consistent', () {
    final m = F1219MBiusA2B1C1D2();
    expect(m.metadata.id, m.id);
  });
}
