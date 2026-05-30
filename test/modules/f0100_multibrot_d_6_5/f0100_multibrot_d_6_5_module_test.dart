// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0100_multibrot_d_6_5/f0100_multibrot_d_6_5_module.dart';

void main() {
  test('F0100MultibrotD65 instantiates', () {
    final m = F0100MultibrotD65();
    expect(m.id, 'f0100_multibrot_d_6_5');
    expect(m.shader, 'shaders/f0100_multibrot_d_6_5_gpu.frag');
  });

  test('F0100MultibrotD65 presets are well-formed', () {
    final m = F0100MultibrotD65();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0100MultibrotD65 metadata is consistent', () {
    final m = F0100MultibrotD65();
    expect(m.metadata.id, m.id);
  });
}
