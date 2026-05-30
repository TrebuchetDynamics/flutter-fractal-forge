// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0152_galaxy_julia/f0152_galaxy_julia_module.dart';

void main() {
  test('F0152GalaxyJulia instantiates', () {
    final m = F0152GalaxyJulia();
    expect(m.id, 'f0152_galaxy_julia');
    expect(m.shader, 'shaders/f0152_galaxy_julia_gpu.frag');
  });

  test('F0152GalaxyJulia presets are well-formed', () {
    final m = F0152GalaxyJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0152GalaxyJulia metadata is consistent', () {
    final m = F0152GalaxyJulia();
    expect(m.metadata.id, m.id);
  });
}
