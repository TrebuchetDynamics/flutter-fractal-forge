// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0099_multibrot_d_5_5/f0099_multibrot_d_5_5_module.dart';

void main() {
  test('F0099MultibrotD55 instantiates', () {
    final m = F0099MultibrotD55();
    expect(m.id, 'f0099_multibrot_d_5_5');
    expect(m.shader, 'shaders/f0099_multibrot_d_5_5_gpu.frag');
  });

  test('F0099MultibrotD55 presets are well-formed', () {
    final m = F0099MultibrotD55();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0099MultibrotD55 metadata is consistent', () {
    final m = F0099MultibrotD55();
    expect(m.metadata.id, m.id);
  });
}
