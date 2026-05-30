// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0102_multibrot_d_8_5/f0102_multibrot_d_8_5_module.dart';

void main() {
  test('F0102MultibrotD85 instantiates', () {
    final m = F0102MultibrotD85();
    expect(m.id, 'f0102_multibrot_d_8_5');
    expect(m.shader, 'shaders/f0102_multibrot_d_8_5_gpu.frag');
  });

  test('F0102MultibrotD85 presets are well-formed', () {
    final m = F0102MultibrotD85();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0102MultibrotD85 metadata is consistent', () {
    final m = F0102MultibrotD85();
    expect(m.metadata.id, m.id);
  });
}
