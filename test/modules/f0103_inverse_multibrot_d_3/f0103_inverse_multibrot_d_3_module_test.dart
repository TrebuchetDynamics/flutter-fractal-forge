// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0103_inverse_multibrot_d_3/f0103_inverse_multibrot_d_3_module.dart';

void main() {
  test('F0103InverseMultibrotD3 instantiates', () {
    final m = F0103InverseMultibrotD3();
    expect(m.id, 'f0103_inverse_multibrot_d_3');
    expect(m.shader, 'shaders/f0103_inverse_multibrot_d_3_gpu.frag');
  });

  test('F0103InverseMultibrotD3 presets are well-formed', () {
    final m = F0103InverseMultibrotD3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0103InverseMultibrotD3 metadata is consistent', () {
    final m = F0103InverseMultibrotD3();
    expect(m.metadata.id, m.id);
  });
}
