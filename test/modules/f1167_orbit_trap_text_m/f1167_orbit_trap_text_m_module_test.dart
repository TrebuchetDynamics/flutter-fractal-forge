// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1167_orbit_trap_text_m/f1167_orbit_trap_text_m_module.dart';

void main() {
  test('F1167OrbitTrapTextM instantiates', () {
    final m = F1167OrbitTrapTextM();
    expect(m.id, 'f1167_orbit_trap_text_m');
    expect(m.shader, 'shaders/f1167_orbit_trap_text_m_gpu.frag');
  });

  test('F1167OrbitTrapTextM presets are well-formed', () {
    final m = F1167OrbitTrapTextM();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1167OrbitTrapTextM metadata is consistent', () {
    final m = F1167OrbitTrapTextM();
    expect(m.metadata.id, m.id);
  });
}
