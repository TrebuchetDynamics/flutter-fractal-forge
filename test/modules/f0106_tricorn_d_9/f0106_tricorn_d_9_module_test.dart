// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0106_tricorn_d_9/f0106_tricorn_d_9_module.dart';

void main() {
  test('F0106TricornD9 instantiates', () {
    final m = F0106TricornD9();
    expect(m.id, 'f0106_tricorn_d_9');
    expect(m.shader, 'shaders/f0106_tricorn_d_9_gpu.frag');
  });

  test('F0106TricornD9 presets are well-formed', () {
    final m = F0106TricornD9();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0106TricornD9 metadata is consistent', () {
    final m = F0106TricornD9();
    expect(m.metadata.id, m.id);
  });
}
