// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0643_phoenix_d_2_p_0_1/f0643_phoenix_d_2_p_0_1_module.dart';

void main() {
  test('F0643PhoenixD2P01 instantiates', () {
    final m = F0643PhoenixD2P01();
    expect(m.id, 'f0643_phoenix_d_2_p_0_1');
    expect(m.shader, 'shaders/f0643_phoenix_d_2_p_0_1_gpu.frag');
  });

  test('F0643PhoenixD2P01 presets are well-formed', () {
    final m = F0643PhoenixD2P01();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0643PhoenixD2P01 metadata is consistent', () {
    final m = F0643PhoenixD2P01();
    expect(m.metadata.id, m.id);
  });
}
