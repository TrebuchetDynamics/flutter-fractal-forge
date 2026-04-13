// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0137_multibrot_z_2_3/f0137_multibrot_z_2_3_module.dart';

void main() {
  test('F0137MultibrotZ23 instantiates', () {
    final m = F0137MultibrotZ23();
    expect(m.id, 'f0137_multibrot_z_2_3');
    expect(m.shader, 'shaders/f0137_multibrot_z_2_3_gpu.frag');
  });

  test('F0137MultibrotZ23 presets are well-formed', () {
    final m = F0137MultibrotZ23();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0137MultibrotZ23 metadata is consistent', () {
    final m = F0137MultibrotZ23();
    expect(m.metadata.id, m.id);
  });
}
