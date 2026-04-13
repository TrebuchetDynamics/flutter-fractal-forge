// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0511_sech_z_c/f0511_sech_z_c_module.dart';

void main() {
  test('F0511SechZC instantiates', () {
    final m = F0511SechZC();
    expect(m.id, 'f0511_sech_z_c');
    expect(m.shader, 'shaders/f0511_sech_z_c_gpu.frag');
  });

  test('F0511SechZC presets are well-formed', () {
    final m = F0511SechZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0511SechZC metadata is consistent', () {
    final m = F0511SechZC();
    expect(m.metadata.id, m.id);
  });
}
