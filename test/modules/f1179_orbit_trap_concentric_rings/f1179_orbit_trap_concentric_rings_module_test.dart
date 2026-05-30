// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1179_orbit_trap_concentric_rings/f1179_orbit_trap_concentric_rings_module.dart';

void main() {
  test('F1179OrbitTrapConcentricRings instantiates', () {
    final m = F1179OrbitTrapConcentricRings();
    expect(m.id, 'f1179_orbit_trap_concentric_rings');
    expect(m.shader, 'shaders/f1179_orbit_trap_concentric_rings_gpu.frag');
  });

  test('F1179OrbitTrapConcentricRings presets are well-formed', () {
    final m = F1179OrbitTrapConcentricRings();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1179OrbitTrapConcentricRings metadata is consistent', () {
    final m = F1179OrbitTrapConcentricRings();
    expect(m.metadata.id, m.id);
  });
}
