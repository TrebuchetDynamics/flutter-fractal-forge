// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0498_sin_z_c/f0498_sin_z_c_module.dart';

void main() {
  test('F0498SinZC instantiates', () {
    final m = F0498SinZC();
    expect(m.id, 'f0498_sin_z_c');
    expect(m.shader, 'shaders/f0498_sin_z_c_gpu.frag');
  });

  test('F0498SinZC presets are well-formed', () {
    final m = F0498SinZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0498SinZC metadata is consistent', () {
    final m = F0498SinZC();
    expect(m.metadata.id, m.id);
  });
}
