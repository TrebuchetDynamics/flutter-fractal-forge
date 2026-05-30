// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1160_orbit_trap_line_real_axis/f1160_orbit_trap_line_real_axis_module.dart';

void main() {
  test('F1160OrbitTrapLineRealAxis instantiates', () {
    final m = F1160OrbitTrapLineRealAxis();
    expect(m.id, 'f1160_orbit_trap_line_real_axis');
    expect(m.shader, 'shaders/f1160_orbit_trap_line_real_axis_gpu.frag');
  });

  test('F1160OrbitTrapLineRealAxis presets are well-formed', () {
    final m = F1160OrbitTrapLineRealAxis();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1160OrbitTrapLineRealAxis metadata is consistent', () {
    final m = F1160OrbitTrapLineRealAxis();
    expect(m.metadata.id, m.id);
  });
}
