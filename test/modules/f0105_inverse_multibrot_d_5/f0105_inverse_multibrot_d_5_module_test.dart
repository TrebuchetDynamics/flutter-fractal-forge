// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0105_inverse_multibrot_d_5/f0105_inverse_multibrot_d_5_module.dart';

void main() {
  test('F0105InverseMultibrotD5 instantiates', () {
    final m = F0105InverseMultibrotD5();
    expect(m.id, 'f0105_inverse_multibrot_d_5');
    expect(m.shader, 'shaders/f0105_inverse_multibrot_d_5_gpu.frag');
  });

  test('F0105InverseMultibrotD5 presets are well-formed', () {
    final m = F0105InverseMultibrotD5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0105InverseMultibrotD5 metadata is consistent', () {
    final m = F0105InverseMultibrotD5();
    expect(m.metadata.id, m.id);
  });
}
