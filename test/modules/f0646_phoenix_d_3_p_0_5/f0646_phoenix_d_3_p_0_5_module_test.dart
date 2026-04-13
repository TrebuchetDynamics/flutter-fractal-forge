// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0646_phoenix_d_3_p_0_5/f0646_phoenix_d_3_p_0_5_module.dart';

void main() {
  test('F0646PhoenixD3P05 instantiates', () {
    final m = F0646PhoenixD3P05();
    expect(m.id, 'f0646_phoenix_d_3_p_0_5');
    expect(m.shader, 'shaders/f0646_phoenix_d_3_p_0_5_gpu.frag');
  });

  test('F0646PhoenixD3P05 presets are well-formed', () {
    final m = F0646PhoenixD3P05();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0646PhoenixD3P05 metadata is consistent', () {
    final m = F0646PhoenixD3P05();
    expect(m.metadata.id, m.id);
  });
}
