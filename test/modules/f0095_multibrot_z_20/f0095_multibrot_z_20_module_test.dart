// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0095_multibrot_z_20/f0095_multibrot_z_20_module.dart';

void main() {
  test('F0095MultibrotZ20 instantiates', () {
    final m = F0095MultibrotZ20();
    expect(m.id, 'f0095_multibrot_z_20');
    expect(m.shader, 'shaders/f0095_multibrot_z_20_gpu.frag');
  });

  test('F0095MultibrotZ20 presets are well-formed', () {
    final m = F0095MultibrotZ20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0095MultibrotZ20 metadata is consistent', () {
    final m = F0095MultibrotZ20();
    expect(m.metadata.id, m.id);
  });
}
