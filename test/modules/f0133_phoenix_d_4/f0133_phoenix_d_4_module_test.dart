// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0133_phoenix_d_4/f0133_phoenix_d_4_module.dart';

void main() {
  test('F0133PhoenixD4 instantiates', () {
    final m = F0133PhoenixD4();
    expect(m.id, 'f0133_phoenix_d_4');
    expect(m.shader, 'shaders/f0133_phoenix_d_4_gpu.frag');
  });

  test('F0133PhoenixD4 presets are well-formed', () {
    final m = F0133PhoenixD4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0133PhoenixD4 metadata is consistent', () {
    final m = F0133PhoenixD4();
    expect(m.metadata.id, m.id);
  });
}
