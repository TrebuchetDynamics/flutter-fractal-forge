// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0514_cot_z_c/f0514_cot_z_c_module.dart';

void main() {
  test('F0514CotZC instantiates', () {
    final m = F0514CotZC();
    expect(m.id, 'f0514_cot_z_c');
    expect(m.shader, 'shaders/f0514_cot_z_c_gpu.frag');
  });

  test('F0514CotZC presets are well-formed', () {
    final m = F0514CotZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0514CotZC metadata is consistent', () {
    final m = F0514CotZC();
    expect(m.metadata.id, m.id);
  });
}
