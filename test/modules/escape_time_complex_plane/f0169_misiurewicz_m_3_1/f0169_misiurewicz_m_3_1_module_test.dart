// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0169_misiurewicz_m_3_1/f0169_misiurewicz_m_3_1_module.dart';

void main() {
  test('F0169MisiurewiczM31 instantiates', () {
    final m = F0169MisiurewiczM31();
    expect(m.id, 'f0169_misiurewicz_m_3_1');
    expect(m.shader, 'shaders/f0169_misiurewicz_m_3_1_gpu.frag');
  });

  test('F0169MisiurewiczM31 presets are well-formed', () {
    final m = F0169MisiurewiczM31();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0169MisiurewiczM31 metadata is consistent', () {
    final m = F0169MisiurewiczM31();
    expect(m.metadata.id, m.id);
  });
}
