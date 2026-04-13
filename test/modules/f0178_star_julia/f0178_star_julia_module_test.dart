// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0178_star_julia/f0178_star_julia_module.dart';

void main() {
  test('F0178StarJulia instantiates', () {
    final m = F0178StarJulia();
    expect(m.id, 'f0178_star_julia');
    expect(m.shader, 'shaders/f0178_star_julia_gpu.frag');
  });

  test('F0178StarJulia presets are well-formed', () {
    final m = F0178StarJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0178StarJulia metadata is consistent', () {
    final m = F0178StarJulia();
    expect(m.metadata.id, m.id);
  });
}
