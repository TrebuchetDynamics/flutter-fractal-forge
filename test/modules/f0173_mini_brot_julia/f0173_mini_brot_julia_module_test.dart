// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0173_mini_brot_julia/f0173_mini_brot_julia_module.dart';

void main() {
  test('F0173MiniBrotJulia instantiates', () {
    final m = F0173MiniBrotJulia();
    expect(m.id, 'f0173_mini_brot_julia');
    expect(m.shader, 'shaders/f0173_mini_brot_julia_gpu.frag');
  });

  test('F0173MiniBrotJulia presets are well-formed', () {
    final m = F0173MiniBrotJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0173MiniBrotJulia metadata is consistent', () {
    final m = F0173MiniBrotJulia();
    expect(m.metadata.id, m.id);
  });
}
