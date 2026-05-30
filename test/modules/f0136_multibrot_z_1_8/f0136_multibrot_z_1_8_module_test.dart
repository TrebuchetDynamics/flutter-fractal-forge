// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0136_multibrot_z_1_8/f0136_multibrot_z_1_8_module.dart';

void main() {
  test('F0136MultibrotZ18 instantiates', () {
    final m = F0136MultibrotZ18();
    expect(m.id, 'f0136_multibrot_z_1_8');
    expect(m.shader, 'shaders/f0136_multibrot_z_1_8_gpu.frag');
  });

  test('F0136MultibrotZ18 presets are well-formed', () {
    final m = F0136MultibrotZ18();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0136MultibrotZ18 metadata is consistent', () {
    final m = F0136MultibrotZ18();
    expect(m.metadata.id, m.id);
  });
}
