// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0101_multibrot_d_7_5/f0101_multibrot_d_7_5_module.dart';

void main() {
  test('F0101MultibrotD75 instantiates', () {
    final m = F0101MultibrotD75();
    expect(m.id, 'f0101_multibrot_d_7_5');
    expect(m.shader, 'shaders/f0101_multibrot_d_7_5_gpu.frag');
  });

  test('F0101MultibrotD75 presets are well-formed', () {
    final m = F0101MultibrotD75();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0101MultibrotD75 metadata is consistent', () {
    final m = F0101MultibrotD75();
    expect(m.metadata.id, m.id);
  });
}
