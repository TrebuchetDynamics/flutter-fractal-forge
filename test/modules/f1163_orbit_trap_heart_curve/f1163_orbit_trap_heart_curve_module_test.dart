// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1163_orbit_trap_heart_curve/f1163_orbit_trap_heart_curve_module.dart';

void main() {
  test('F1163OrbitTrapHeartCurve instantiates', () {
    final m = F1163OrbitTrapHeartCurve();
    expect(m.id, 'f1163_orbit_trap_heart_curve');
    expect(m.shader, 'shaders/f1163_orbit_trap_heart_curve_gpu.frag');
  });

  test('F1163OrbitTrapHeartCurve presets are well-formed', () {
    final m = F1163OrbitTrapHeartCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1163OrbitTrapHeartCurve metadata is consistent', () {
    final m = F1163OrbitTrapHeartCurve();
    expect(m.metadata.id, m.id);
  });
}
