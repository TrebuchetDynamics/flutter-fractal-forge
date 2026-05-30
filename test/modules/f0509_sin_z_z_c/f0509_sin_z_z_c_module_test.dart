// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0509_sin_z_z_c/f0509_sin_z_z_c_module.dart';

void main() {
  test('F0509SinZZC instantiates', () {
    final m = F0509SinZZC();
    expect(m.id, 'f0509_sin_z_z_c');
    expect(m.shader, 'shaders/f0509_sin_z_z_c_gpu.frag');
  });

  test('F0509SinZZC presets are well-formed', () {
    final m = F0509SinZZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0509SinZZC metadata is consistent', () {
    final m = F0509SinZZC();
    expect(m.metadata.id, m.id);
  });
}
