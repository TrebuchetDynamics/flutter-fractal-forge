// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0108_tricorn_d_11/f0108_tricorn_d_11_module.dart';

void main() {
  test('F0108TricornD11 instantiates', () {
    final m = F0108TricornD11();
    expect(m.id, 'f0108_tricorn_d_11');
    expect(m.shader, 'shaders/f0108_tricorn_d_11_gpu.frag');
  });

  test('F0108TricornD11 presets are well-formed', () {
    final m = F0108TricornD11();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0108TricornD11 metadata is consistent', () {
    final m = F0108TricornD11();
    expect(m.metadata.id, m.id);
  });
}
