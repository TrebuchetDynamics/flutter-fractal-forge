// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0517_sin_z_1_c/f0517_sin_z_1_c_module.dart';

void main() {
  test('F0517SinZ1C instantiates', () {
    final m = F0517SinZ1C();
    expect(m.id, 'f0517_sin_z_1_c');
    expect(m.shader, 'shaders/f0517_sin_z_1_c_gpu.frag');
  });

  test('F0517SinZ1C presets are well-formed', () {
    final m = F0517SinZ1C();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0517SinZ1C metadata is consistent', () {
    final m = F0517SinZ1C();
    expect(m.metadata.id, m.id);
  });
}
