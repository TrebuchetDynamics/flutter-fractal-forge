// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0090_multibrot_z_15/f0090_multibrot_z_15_module.dart';

void main() {
  test('F0090MultibrotZ15 instantiates', () {
    final m = F0090MultibrotZ15();
    expect(m.id, 'f0090_multibrot_z_15');
    expect(m.shader, 'shaders/f0090_multibrot_z_15_gpu.frag');
  });

  test('F0090MultibrotZ15 presets are well-formed', () {
    final m = F0090MultibrotZ15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0090MultibrotZ15 metadata is consistent', () {
    final m = F0090MultibrotZ15();
    expect(m.metadata.id, m.id);
  });
}
