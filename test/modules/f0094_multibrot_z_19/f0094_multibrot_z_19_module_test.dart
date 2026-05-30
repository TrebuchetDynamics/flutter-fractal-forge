// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0094_multibrot_z_19/f0094_multibrot_z_19_module.dart';

void main() {
  test('F0094MultibrotZ19 instantiates', () {
    final m = F0094MultibrotZ19();
    expect(m.id, 'f0094_multibrot_z_19');
    expect(m.shader, 'shaders/f0094_multibrot_z_19_gpu.frag');
  });

  test('F0094MultibrotZ19 presets are well-formed', () {
    final m = F0094MultibrotZ19();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0094MultibrotZ19 metadata is consistent', () {
    final m = F0094MultibrotZ19();
    expect(m.metadata.id, m.id);
  });
}
