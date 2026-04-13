// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0502_sin_1_z_c/f0502_sin_1_z_c_module.dart';

void main() {
  test('F0502Sin1ZC instantiates', () {
    final m = F0502Sin1ZC();
    expect(m.id, 'f0502_sin_1_z_c');
    expect(m.shader, 'shaders/f0502_sin_1_z_c_gpu.frag');
  });

  test('F0502Sin1ZC presets are well-formed', () {
    final m = F0502Sin1ZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0502Sin1ZC metadata is consistent', () {
    final m = F0502Sin1ZC();
    expect(m.metadata.id, m.id);
  });
}
