// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0521_sin_z_c/f0521_sin_z_c_module.dart';

void main() {
  test('F0521SinZC instantiates', () {
    final m = F0521SinZC();
    expect(m.id, 'f0521_sin_z_c');
    expect(m.shader, 'shaders/f0521_sin_z_c_gpu.frag');
  });

  test('F0521SinZC presets are well-formed', () {
    final m = F0521SinZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0521SinZC metadata is consistent', () {
    final m = F0521SinZC();
    expect(m.metadata.id, m.id);
  });
}
