// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0132_phoenix_d_3/f0132_phoenix_d_3_module.dart';

void main() {
  test('F0132PhoenixD3 instantiates', () {
    final m = F0132PhoenixD3();
    expect(m.id, 'f0132_phoenix_d_3');
    expect(m.shader, 'shaders/f0132_phoenix_d_3_gpu.frag');
  });

  test('F0132PhoenixD3 presets are well-formed', () {
    final m = F0132PhoenixD3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0132PhoenixD3 metadata is consistent', () {
    final m = F0132PhoenixD3();
    expect(m.metadata.id, m.id);
  });
}
