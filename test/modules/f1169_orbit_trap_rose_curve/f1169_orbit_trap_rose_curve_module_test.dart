// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1169_orbit_trap_rose_curve/f1169_orbit_trap_rose_curve_module.dart';

void main() {
  test('F1169OrbitTrapRoseCurve instantiates', () {
    final m = F1169OrbitTrapRoseCurve();
    expect(m.id, 'f1169_orbit_trap_rose_curve');
    expect(m.shader, 'shaders/f1169_orbit_trap_rose_curve_gpu.frag');
  });

  test('F1169OrbitTrapRoseCurve presets are well-formed', () {
    final m = F1169OrbitTrapRoseCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1169OrbitTrapRoseCurve metadata is consistent', () {
    final m = F1169OrbitTrapRoseCurve();
    expect(m.metadata.id, m.id);
  });
}
