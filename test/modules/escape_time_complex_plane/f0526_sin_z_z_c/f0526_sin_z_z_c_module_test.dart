// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0526_sin_z_z_c/f0526_sin_z_z_c_module.dart';

void main() {
  test('F0526SinZZC instantiates', () {
    final m = F0526SinZZC();
    expect(m.id, 'f0526_sin_z_z_c');
    expect(m.shader, 'shaders/f0526_sin_z_z_c_gpu.frag');
  });

  test('F0526SinZZC presets are well-formed', () {
    final m = F0526SinZZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0526SinZZC metadata is consistent', () {
    final m = F0526SinZZC();
    expect(m.metadata.id, m.id);
  });
}
