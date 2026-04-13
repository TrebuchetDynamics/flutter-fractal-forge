// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0089_multibrot_z_14/f0089_multibrot_z_14_module.dart';

void main() {
  test('F0089MultibrotZ14 instantiates', () {
    final m = F0089MultibrotZ14();
    expect(m.id, 'f0089_multibrot_z_14');
    expect(m.shader, 'shaders/f0089_multibrot_z_14_gpu.frag');
  });

  test('F0089MultibrotZ14 presets are well-formed', () {
    final m = F0089MultibrotZ14();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0089MultibrotZ14 metadata is consistent', () {
    final m = F0089MultibrotZ14();
    expect(m.metadata.id, m.id);
  });
}
