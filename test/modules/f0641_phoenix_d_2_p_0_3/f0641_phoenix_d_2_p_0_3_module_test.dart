// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0641_phoenix_d_2_p_0_3/f0641_phoenix_d_2_p_0_3_module.dart';

void main() {
  test('F0641PhoenixD2P03 instantiates', () {
    final m = F0641PhoenixD2P03();
    expect(m.id, 'f0641_phoenix_d_2_p_0_3');
    expect(m.shader, 'shaders/f0641_phoenix_d_2_p_0_3_gpu.frag');
  });

  test('F0641PhoenixD2P03 presets are well-formed', () {
    final m = F0641PhoenixD2P03();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0641PhoenixD2P03 metadata is consistent', () {
    final m = F0641PhoenixD2P03();
    expect(m.metadata.id, m.id);
  });
}
