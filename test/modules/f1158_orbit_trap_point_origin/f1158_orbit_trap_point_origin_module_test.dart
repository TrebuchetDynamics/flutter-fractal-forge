// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1158_orbit_trap_point_origin/f1158_orbit_trap_point_origin_module.dart';

void main() {
  test('F1158OrbitTrapPointOrigin instantiates', () {
    final m = F1158OrbitTrapPointOrigin();
    expect(m.id, 'f1158_orbit_trap_point_origin');
    expect(m.shader, 'shaders/f1158_orbit_trap_point_origin_gpu.frag');
  });

  test('F1158OrbitTrapPointOrigin presets are well-formed', () {
    final m = F1158OrbitTrapPointOrigin();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1158OrbitTrapPointOrigin metadata is consistent', () {
    final m = F1158OrbitTrapPointOrigin();
    expect(m.metadata.id, m.id);
  });
}
