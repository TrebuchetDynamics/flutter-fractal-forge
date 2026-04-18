// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1165_orbit_trap_spiral/f1165_orbit_trap_spiral_module.dart';

void main() {
  test('F1165OrbitTrapSpiral instantiates', () {
    final m = F1165OrbitTrapSpiral();
    expect(m.id, 'f1165_orbit_trap_spiral');
    expect(m.shader, 'shaders/f1165_orbit_trap_spiral_gpu.frag');
  });

  test('F1165OrbitTrapSpiral presets are well-formed', () {
    final m = F1165OrbitTrapSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1165OrbitTrapSpiral metadata is consistent', () {
    final m = F1165OrbitTrapSpiral();
    expect(m.metadata.id, m.id);
  });
}
