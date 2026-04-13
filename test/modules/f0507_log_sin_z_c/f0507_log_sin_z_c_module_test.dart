// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0507_log_sin_z_c/f0507_log_sin_z_c_module.dart';

void main() {
  test('F0507LogSinZC instantiates', () {
    final m = F0507LogSinZC();
    expect(m.id, 'f0507_log_sin_z_c');
    expect(m.shader, 'shaders/f0507_log_sin_z_c_gpu.frag');
  });

  test('F0507LogSinZC presets are well-formed', () {
    final m = F0507LogSinZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0507LogSinZC metadata is consistent', () {
    final m = F0507LogSinZC();
    expect(m.metadata.id, m.id);
  });
}
