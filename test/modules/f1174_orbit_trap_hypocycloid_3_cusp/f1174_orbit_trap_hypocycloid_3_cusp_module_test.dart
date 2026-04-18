// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1174_orbit_trap_hypocycloid_3_cusp/f1174_orbit_trap_hypocycloid_3_cusp_module.dart';

void main() {
  test('F1174OrbitTrapHypocycloid3Cusp instantiates', () {
    final m = F1174OrbitTrapHypocycloid3Cusp();
    expect(m.id, 'f1174_orbit_trap_hypocycloid_3_cusp');
    expect(m.shader, 'shaders/f1174_orbit_trap_hypocycloid_3_cusp_gpu.frag');
  });

  test('F1174OrbitTrapHypocycloid3Cusp presets are well-formed', () {
    final m = F1174OrbitTrapHypocycloid3Cusp();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1174OrbitTrapHypocycloid3Cusp metadata is consistent', () {
    final m = F1174OrbitTrapHypocycloid3Cusp();
    expect(m.metadata.id, m.id);
  });
}
