// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1172_orbit_trap_lemniscate/f1172_orbit_trap_lemniscate_module.dart';

void main() {
  test('F1172OrbitTrapLemniscate instantiates', () {
    final m = F1172OrbitTrapLemniscate();
    expect(m.id, 'f1172_orbit_trap_lemniscate');
    expect(m.shader, 'shaders/f1172_orbit_trap_lemniscate_gpu.frag');
  });

  test('F1172OrbitTrapLemniscate presets are well-formed', () {
    final m = F1172OrbitTrapLemniscate();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1172OrbitTrapLemniscate metadata is consistent', () {
    final m = F1172OrbitTrapLemniscate();
    expect(m.metadata.id, m.id);
  });
}
