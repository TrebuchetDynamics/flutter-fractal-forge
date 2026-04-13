// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0149_cactus_julia/f0149_cactus_julia_module.dart';

void main() {
  test('F0149CactusJulia instantiates', () {
    final m = F0149CactusJulia();
    expect(m.id, 'f0149_cactus_julia');
    expect(m.shader, 'shaders/f0149_cactus_julia_gpu.frag');
  });

  test('F0149CactusJulia presets are well-formed', () {
    final m = F0149CactusJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0149CactusJulia metadata is consistent', () {
    final m = F0149CactusJulia();
    expect(m.metadata.id, m.id);
  });
}
