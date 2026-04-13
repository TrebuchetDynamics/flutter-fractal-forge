// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0107_tricorn_d_10/f0107_tricorn_d_10_module.dart';

void main() {
  test('F0107TricornD10 instantiates', () {
    final m = F0107TricornD10();
    expect(m.id, 'f0107_tricorn_d_10');
    expect(m.shader, 'shaders/f0107_tricorn_d_10_gpu.frag');
  });

  test('F0107TricornD10 presets are well-formed', () {
    final m = F0107TricornD10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0107TricornD10 metadata is consistent', () {
    final m = F0107TricornD10();
    expect(m.metadata.id, m.id);
  });
}
