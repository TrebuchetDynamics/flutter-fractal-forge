// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0201_northern_light_julia/f0201_northern_light_julia_module.dart';

void main() {
  test('F0201NorthernLightJulia instantiates', () {
    final m = F0201NorthernLightJulia();
    expect(m.id, 'f0201_northern_light_julia');
    expect(m.shader, 'shaders/f0201_northern_light_julia_gpu.frag');
  });

  test('F0201NorthernLightJulia presets are well-formed', () {
    final m = F0201NorthernLightJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0201NorthernLightJulia metadata is consistent', () {
    final m = F0201NorthernLightJulia();
    expect(m.metadata.id, m.id);
  });
}
