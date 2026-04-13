// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0644_phoenix_d_2_p_0_25/f0644_phoenix_d_2_p_0_25_module.dart';

void main() {
  test('F0644PhoenixD2P025 instantiates', () {
    final m = F0644PhoenixD2P025();
    expect(m.id, 'f0644_phoenix_d_2_p_0_25');
    expect(m.shader, 'shaders/f0644_phoenix_d_2_p_0_25_gpu.frag');
  });

  test('F0644PhoenixD2P025 presets are well-formed', () {
    final m = F0644PhoenixD2P025();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0644PhoenixD2P025 metadata is consistent', () {
    final m = F0644PhoenixD2P025();
    expect(m.metadata.id, m.id);
  });
}
