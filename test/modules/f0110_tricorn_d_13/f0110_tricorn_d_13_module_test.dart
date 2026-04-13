// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0110_tricorn_d_13/f0110_tricorn_d_13_module.dart';

void main() {
  test('F0110TricornD13 instantiates', () {
    final m = F0110TricornD13();
    expect(m.id, 'f0110_tricorn_d_13');
    expect(m.shader, 'shaders/f0110_tricorn_d_13_gpu.frag');
  });

  test('F0110TricornD13 presets are well-formed', () {
    final m = F0110TricornD13();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0110TricornD13 metadata is consistent', () {
    final m = F0110TricornD13();
    expect(m.metadata.id, m.id);
  });
}
