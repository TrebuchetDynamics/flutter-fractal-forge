// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0179_misiurewicz_m_4_1/f0179_misiurewicz_m_4_1_module.dart';

void main() {
  test('F0179MisiurewiczM41 instantiates', () {
    final m = F0179MisiurewiczM41();
    expect(m.id, 'f0179_misiurewicz_m_4_1');
    expect(m.shader, 'shaders/f0179_misiurewicz_m_4_1_gpu.frag');
  });

  test('F0179MisiurewiczM41 presets are well-formed', () {
    final m = F0179MisiurewiczM41();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0179MisiurewiczM41 metadata is consistent', () {
    final m = F0179MisiurewiczM41();
    expect(m.metadata.id, m.id);
  });
}
