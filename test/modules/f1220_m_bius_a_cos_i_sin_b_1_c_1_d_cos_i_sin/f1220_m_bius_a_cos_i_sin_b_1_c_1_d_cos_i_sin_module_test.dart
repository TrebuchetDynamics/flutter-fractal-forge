// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin/f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_module.dart';

void main() {
  test('F1220MBiusACosISinB1C1DCosISin instantiates', () {
    final m = F1220MBiusACosISinB1C1DCosISin();
    expect(m.id, 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin');
    expect(m.shader, 'shaders/f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_gpu.frag');
  });

  test('F1220MBiusACosISinB1C1DCosISin presets are well-formed', () {
    final m = F1220MBiusACosISinB1C1DCosISin();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1220MBiusACosISinB1C1DCosISin metadata is consistent', () {
    final m = F1220MBiusACosISinB1C1DCosISin();
    expect(m.metadata.id, m.id);
  });
}
