// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0168_misiurewicz_m_2_1/f0168_misiurewicz_m_2_1_module.dart';

void main() {
  test('F0168MisiurewiczM21 instantiates', () {
    final m = F0168MisiurewiczM21();
    expect(m.id, 'f0168_misiurewicz_m_2_1');
    expect(m.shader, 'shaders/f0168_misiurewicz_m_2_1_gpu.frag');
  });

  test('F0168MisiurewiczM21 presets are well-formed', () {
    final m = F0168MisiurewiczM21();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0168MisiurewiczM21 metadata is consistent', () {
    final m = F0168MisiurewiczM21();
    expect(m.metadata.id, m.id);
  });
}
