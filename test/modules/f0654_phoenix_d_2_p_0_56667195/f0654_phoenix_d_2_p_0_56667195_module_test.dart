// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0654_phoenix_d_2_p_0_56667195/f0654_phoenix_d_2_p_0_56667195_module.dart';

void main() {
  test('F0654PhoenixD2P056667195 instantiates', () {
    final m = F0654PhoenixD2P056667195();
    expect(m.id, 'f0654_phoenix_d_2_p_0_56667195');
    expect(m.shader, 'shaders/f0654_phoenix_d_2_p_0_56667195_gpu.frag');
  });

  test('F0654PhoenixD2P056667195 presets are well-formed', () {
    final m = F0654PhoenixD2P056667195();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0654PhoenixD2P056667195 metadata is consistent', () {
    final m = F0654PhoenixD2P056667195();
    expect(m.metadata.id, m.id);
  });
}
