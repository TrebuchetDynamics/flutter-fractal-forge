// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0109_tricorn_d_12/f0109_tricorn_d_12_module.dart';

void main() {
  test('F0109TricornD12 instantiates', () {
    final m = F0109TricornD12();
    expect(m.id, 'f0109_tricorn_d_12');
    expect(m.shader, 'shaders/f0109_tricorn_d_12_gpu.frag');
  });

  test('F0109TricornD12 presets are well-formed', () {
    final m = F0109TricornD12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0109TricornD12 metadata is consistent', () {
    final m = F0109TricornD12();
    expect(m.metadata.id, m.id);
  });
}
