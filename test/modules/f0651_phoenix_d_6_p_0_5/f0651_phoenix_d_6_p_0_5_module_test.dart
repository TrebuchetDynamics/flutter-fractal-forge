// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0651_phoenix_d_6_p_0_5/f0651_phoenix_d_6_p_0_5_module.dart';

void main() {
  test('F0651PhoenixD6P05 instantiates', () {
    final m = F0651PhoenixD6P05();
    expect(m.id, 'f0651_phoenix_d_6_p_0_5');
    expect(m.shader, 'shaders/f0651_phoenix_d_6_p_0_5_gpu.frag');
  });

  test('F0651PhoenixD6P05 presets are well-formed', () {
    final m = F0651PhoenixD6P05();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0651PhoenixD6P05 metadata is consistent', () {
    final m = F0651PhoenixD6P05();
    expect(m.metadata.id, m.id);
  });
}
