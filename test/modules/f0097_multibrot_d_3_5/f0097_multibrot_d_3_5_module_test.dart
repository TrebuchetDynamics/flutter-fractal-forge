// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0097_multibrot_d_3_5/f0097_multibrot_d_3_5_module.dart';

void main() {
  test('F0097MultibrotD35 instantiates', () {
    final m = F0097MultibrotD35();
    expect(m.id, 'f0097_multibrot_d_3_5');
    expect(m.shader, 'shaders/f0097_multibrot_d_3_5_gpu.frag');
  });

  test('F0097MultibrotD35 presets are well-formed', () {
    final m = F0097MultibrotD35();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0097MultibrotD35 metadata is consistent', () {
    final m = F0097MultibrotD35();
    expect(m.metadata.id, m.id);
  });
}
