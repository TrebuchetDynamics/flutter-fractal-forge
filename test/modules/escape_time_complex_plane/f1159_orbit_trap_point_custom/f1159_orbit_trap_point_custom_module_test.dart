// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1159_orbit_trap_point_custom/f1159_orbit_trap_point_custom_module.dart';

void main() {
  test('F1159OrbitTrapPointCustom instantiates', () {
    final m = F1159OrbitTrapPointCustom();
    expect(m.id, 'f1159_orbit_trap_point_custom');
    expect(m.shader, 'shaders/f1159_orbit_trap_point_custom_gpu.frag');
  });

  test('F1159OrbitTrapPointCustom presets are well-formed', () {
    final m = F1159OrbitTrapPointCustom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1159OrbitTrapPointCustom metadata is consistent', () {
    final m = F1159OrbitTrapPointCustom();
    expect(m.metadata.id, m.id);
  });
}
