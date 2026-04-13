// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0190_broccoli_julia/f0190_broccoli_julia_module.dart';

void main() {
  test('F0190BroccoliJulia instantiates', () {
    final m = F0190BroccoliJulia();
    expect(m.id, 'f0190_broccoli_julia');
    expect(m.shader, 'shaders/f0190_broccoli_julia_gpu.frag');
  });

  test('F0190BroccoliJulia presets are well-formed', () {
    final m = F0190BroccoliJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0190BroccoliJulia metadata is consistent', () {
    final m = F0190BroccoliJulia();
    expect(m.metadata.id, m.id);
  });
}
