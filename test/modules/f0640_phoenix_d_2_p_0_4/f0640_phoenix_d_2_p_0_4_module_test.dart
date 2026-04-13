// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0640_phoenix_d_2_p_0_4/f0640_phoenix_d_2_p_0_4_module.dart';

void main() {
  test('F0640PhoenixD2P04 instantiates', () {
    final m = F0640PhoenixD2P04();
    expect(m.id, 'f0640_phoenix_d_2_p_0_4');
    expect(m.shader, 'shaders/f0640_phoenix_d_2_p_0_4_gpu.frag');
  });

  test('F0640PhoenixD2P04 presets are well-formed', () {
    final m = F0640PhoenixD2P04();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0640PhoenixD2P04 metadata is consistent', () {
    final m = F0640PhoenixD2P04();
    expect(m.metadata.id, m.id);
  });
}
