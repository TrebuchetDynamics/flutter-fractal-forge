// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0523_exp_z_z_c/f0523_exp_z_z_c_module.dart';

void main() {
  test('F0523ExpZZC instantiates', () {
    final m = F0523ExpZZC();
    expect(m.id, 'f0523_exp_z_z_c');
    expect(m.shader, 'shaders/f0523_exp_z_z_c_gpu.frag');
  });

  test('F0523ExpZZC presets are well-formed', () {
    final m = F0523ExpZZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0523ExpZZC metadata is consistent', () {
    final m = F0523ExpZZC();
    expect(m.metadata.id, m.id);
  });
}
