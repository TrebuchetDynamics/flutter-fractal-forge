// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0088_multibrot_z_13/f0088_multibrot_z_13_module.dart';

void main() {
  test('F0088MultibrotZ13 instantiates', () {
    final m = F0088MultibrotZ13();
    expect(m.id, 'f0088_multibrot_z_13');
    expect(m.shader, 'shaders/f0088_multibrot_z_13_gpu.frag');
  });

  test('F0088MultibrotZ13 presets are well-formed', () {
    final m = F0088MultibrotZ13();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0088MultibrotZ13 metadata is consistent', () {
    final m = F0088MultibrotZ13();
    expect(m.metadata.id, m.id);
  });
}
