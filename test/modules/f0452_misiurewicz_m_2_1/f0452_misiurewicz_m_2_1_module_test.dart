// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0452_misiurewicz_m_2_1/f0452_misiurewicz_m_2_1_module.dart';

void main() {
  test('F0452MisiurewiczM21 instantiates', () {
    final m = F0452MisiurewiczM21();
    expect(m.id, 'f0452_misiurewicz_m_2_1');
    expect(m.shader, 'shaders/f0452_misiurewicz_m_2_1_gpu.frag');
  });

  test('F0452MisiurewiczM21 presets are well-formed', () {
    final m = F0452MisiurewiczM21();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0452MisiurewiczM21 metadata is consistent', () {
    final m = F0452MisiurewiczM21();
    expect(m.metadata.id, m.id);
  });
}
