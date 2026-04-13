// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0527_cos_z_z_c/f0527_cos_z_z_c_module.dart';

void main() {
  test('F0527CosZZC instantiates', () {
    final m = F0527CosZZC();
    expect(m.id, 'f0527_cos_z_z_c');
    expect(m.shader, 'shaders/f0527_cos_z_z_c_gpu.frag');
  });

  test('F0527CosZZC presets are well-formed', () {
    final m = F0527CosZZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0527CosZZC metadata is consistent', () {
    final m = F0527CosZZC();
    expect(m.metadata.id, m.id);
  });
}
