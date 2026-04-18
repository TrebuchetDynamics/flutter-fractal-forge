// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1164_orbit_trap_star_5_pointed/f1164_orbit_trap_star_5_pointed_module.dart';

void main() {
  test('F1164OrbitTrapStar5Pointed instantiates', () {
    final m = F1164OrbitTrapStar5Pointed();
    expect(m.id, 'f1164_orbit_trap_star_5_pointed');
    expect(m.shader, 'shaders/f1164_orbit_trap_star_5_pointed_gpu.frag');
  });

  test('F1164OrbitTrapStar5Pointed presets are well-formed', () {
    final m = F1164OrbitTrapStar5Pointed();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1164OrbitTrapStar5Pointed metadata is consistent', () {
    final m = F1164OrbitTrapStar5Pointed();
    expect(m.metadata.id, m.id);
  });
}
