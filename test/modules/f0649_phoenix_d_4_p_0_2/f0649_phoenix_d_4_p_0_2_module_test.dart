// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0649_phoenix_d_4_p_0_2/f0649_phoenix_d_4_p_0_2_module.dart';

void main() {
  test('F0649PhoenixD4P02 instantiates', () {
    final m = F0649PhoenixD4P02();
    expect(m.id, 'f0649_phoenix_d_4_p_0_2');
    expect(m.shader, 'shaders/f0649_phoenix_d_4_p_0_2_gpu.frag');
  });

  test('F0649PhoenixD4P02 presets are well-formed', () {
    final m = F0649PhoenixD4P02();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0649PhoenixD4P02 metadata is consistent', () {
    final m = F0649PhoenixD4P02();
    expect(m.metadata.id, m.id);
  });
}
