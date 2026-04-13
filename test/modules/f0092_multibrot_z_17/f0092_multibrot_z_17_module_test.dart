// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0092_multibrot_z_17/f0092_multibrot_z_17_module.dart';

void main() {
  test('F0092MultibrotZ17 instantiates', () {
    final m = F0092MultibrotZ17();
    expect(m.id, 'f0092_multibrot_z_17');
    expect(m.shader, 'shaders/f0092_multibrot_z_17_gpu.frag');
  });

  test('F0092MultibrotZ17 presets are well-formed', () {
    final m = F0092MultibrotZ17();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0092MultibrotZ17 metadata is consistent', () {
    final m = F0092MultibrotZ17();
    expect(m.metadata.id, m.id);
  });
}
