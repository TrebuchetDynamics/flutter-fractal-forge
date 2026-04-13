// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0104_inverse_multibrot_d_4/f0104_inverse_multibrot_d_4_module.dart';

void main() {
  test('F0104InverseMultibrotD4 instantiates', () {
    final m = F0104InverseMultibrotD4();
    expect(m.id, 'f0104_inverse_multibrot_d_4');
    expect(m.shader, 'shaders/f0104_inverse_multibrot_d_4_gpu.frag');
  });

  test('F0104InverseMultibrotD4 presets are well-formed', () {
    final m = F0104InverseMultibrotD4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0104InverseMultibrotD4 metadata is consistent', () {
    final m = F0104InverseMultibrotD4();
    expect(m.metadata.id, m.id);
  });
}
