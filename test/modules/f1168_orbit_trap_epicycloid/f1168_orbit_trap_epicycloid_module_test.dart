// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1168_orbit_trap_epicycloid/f1168_orbit_trap_epicycloid_module.dart';

void main() {
  test('F1168OrbitTrapEpicycloid instantiates', () {
    final m = F1168OrbitTrapEpicycloid();
    expect(m.id, 'f1168_orbit_trap_epicycloid');
    expect(m.shader, 'shaders/f1168_orbit_trap_epicycloid_gpu.frag');
  });

  test('F1168OrbitTrapEpicycloid presets are well-formed', () {
    final m = F1168OrbitTrapEpicycloid();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1168OrbitTrapEpicycloid metadata is consistent', () {
    final m = F1168OrbitTrapEpicycloid();
    expect(m.metadata.id, m.id);
  });
}
