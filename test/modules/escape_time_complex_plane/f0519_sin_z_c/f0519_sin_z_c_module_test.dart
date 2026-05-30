// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0519_sin_z_c/f0519_sin_z_c_module.dart';

void main() {
  test('F0519SinZC instantiates', () {
    final m = F0519SinZC();
    expect(m.id, 'f0519_sin_z_c');
    expect(m.shader, 'shaders/f0519_sin_z_c_gpu.frag');
  });

  test('F0519SinZC presets are well-formed', () {
    final m = F0519SinZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0519SinZC metadata is consistent', () {
    final m = F0519SinZC();
    expect(m.metadata.id, m.id);
  });
}
