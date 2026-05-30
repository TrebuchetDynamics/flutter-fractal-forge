// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0112_tricorn_d_15/f0112_tricorn_d_15_module.dart';

void main() {
  test('F0112TricornD15 instantiates', () {
    final m = F0112TricornD15();
    expect(m.id, 'f0112_tricorn_d_15');
    expect(m.shader, 'shaders/f0112_tricorn_d_15_gpu.frag');
  });

  test('F0112TricornD15 presets are well-formed', () {
    final m = F0112TricornD15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0112TricornD15 metadata is consistent', () {
    final m = F0112TricornD15();
    expect(m.metadata.id, m.id);
  });
}
