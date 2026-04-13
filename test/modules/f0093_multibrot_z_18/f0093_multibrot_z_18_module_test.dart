// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0093_multibrot_z_18/f0093_multibrot_z_18_module.dart';

void main() {
  test('F0093MultibrotZ18 instantiates', () {
    final m = F0093MultibrotZ18();
    expect(m.id, 'f0093_multibrot_z_18');
    expect(m.shader, 'shaders/f0093_multibrot_z_18_gpu.frag');
  });

  test('F0093MultibrotZ18 presets are well-formed', () {
    final m = F0093MultibrotZ18();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0093MultibrotZ18 metadata is consistent', () {
    final m = F0093MultibrotZ18();
    expect(m.metadata.id, m.id);
  });
}
