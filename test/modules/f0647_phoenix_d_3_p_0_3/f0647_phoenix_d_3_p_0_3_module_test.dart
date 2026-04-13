// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0647_phoenix_d_3_p_0_3/f0647_phoenix_d_3_p_0_3_module.dart';

void main() {
  test('F0647PhoenixD3P03 instantiates', () {
    final m = F0647PhoenixD3P03();
    expect(m.id, 'f0647_phoenix_d_3_p_0_3');
    expect(m.shader, 'shaders/f0647_phoenix_d_3_p_0_3_gpu.frag');
  });

  test('F0647PhoenixD3P03 presets are well-formed', () {
    final m = F0647PhoenixD3P03();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0647PhoenixD3P03 metadata is consistent', () {
    final m = F0647PhoenixD3P03();
    expect(m.metadata.id, m.id);
  });
}
