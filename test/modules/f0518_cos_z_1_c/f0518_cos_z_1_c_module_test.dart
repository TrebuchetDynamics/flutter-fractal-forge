// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0518_cos_z_1_c/f0518_cos_z_1_c_module.dart';

void main() {
  test('F0518CosZ1C instantiates', () {
    final m = F0518CosZ1C();
    expect(m.id, 'f0518_cos_z_1_c');
    expect(m.shader, 'shaders/f0518_cos_z_1_c_gpu.frag');
  });

  test('F0518CosZ1C presets are well-formed', () {
    final m = F0518CosZ1C();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0518CosZ1C metadata is consistent', () {
    final m = F0518CosZ1C();
    expect(m.metadata.id, m.id);
  });
}
