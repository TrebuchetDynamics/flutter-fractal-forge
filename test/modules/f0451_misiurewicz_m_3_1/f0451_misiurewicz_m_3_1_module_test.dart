// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0451_misiurewicz_m_3_1/f0451_misiurewicz_m_3_1_module.dart';

void main() {
  test('F0451MisiurewiczM31 instantiates', () {
    final m = F0451MisiurewiczM31();
    expect(m.id, 'f0451_misiurewicz_m_3_1');
    expect(m.shader, 'shaders/f0451_misiurewicz_m_3_1_gpu.frag');
  });

  test('F0451MisiurewiczM31 presets are well-formed', () {
    final m = F0451MisiurewiczM31();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0451MisiurewiczM31 metadata is consistent', () {
    final m = F0451MisiurewiczM31();
    expect(m.metadata.id, m.id);
  });
}
