// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0642_phoenix_d_2_p_0_2/f0642_phoenix_d_2_p_0_2_module.dart';

void main() {
  test('F0642PhoenixD2P02 instantiates', () {
    final m = F0642PhoenixD2P02();
    expect(m.id, 'f0642_phoenix_d_2_p_0_2');
    expect(m.shader, 'shaders/f0642_phoenix_d_2_p_0_2_gpu.frag');
  });

  test('F0642PhoenixD2P02 presets are well-formed', () {
    final m = F0642PhoenixD2P02();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0642PhoenixD2P02 metadata is consistent', () {
    final m = F0642PhoenixD2P02();
    expect(m.metadata.id, m.id);
  });
}
