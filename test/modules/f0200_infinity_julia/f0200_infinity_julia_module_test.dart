// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0200_infinity_julia/f0200_infinity_julia_module.dart';

void main() {
  test('F0200InfinityJulia instantiates', () {
    final m = F0200InfinityJulia();
    expect(m.id, 'f0200_infinity_julia');
    expect(m.shader, 'shaders/f0200_infinity_julia_gpu.frag');
  });

  test('F0200InfinityJulia presets are well-formed', () {
    final m = F0200InfinityJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0200InfinityJulia metadata is consistent', () {
    final m = F0200InfinityJulia();
    expect(m.metadata.id, m.id);
  });
}
