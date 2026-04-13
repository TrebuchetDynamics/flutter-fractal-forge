// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0145_seahorse_valley_julia/f0145_seahorse_valley_julia_module.dart';

void main() {
  test('F0145SeahorseValleyJulia instantiates', () {
    final m = F0145SeahorseValleyJulia();
    expect(m.id, 'f0145_seahorse_valley_julia');
    expect(m.shader, 'shaders/f0145_seahorse_valley_julia_gpu.frag');
  });

  test('F0145SeahorseValleyJulia presets are well-formed', () {
    final m = F0145SeahorseValleyJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0145SeahorseValleyJulia metadata is consistent', () {
    final m = F0145SeahorseValleyJulia();
    expect(m.metadata.id, m.id);
  });
}
