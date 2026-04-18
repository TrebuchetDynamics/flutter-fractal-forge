// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1161_orbit_trap_line_imaginary_axis/f1161_orbit_trap_line_imaginary_axis_module.dart';

void main() {
  test('F1161OrbitTrapLineImaginaryAxis instantiates', () {
    final m = F1161OrbitTrapLineImaginaryAxis();
    expect(m.id, 'f1161_orbit_trap_line_imaginary_axis');
    expect(m.shader, 'shaders/f1161_orbit_trap_line_imaginary_axis_gpu.frag');
  });

  test('F1161OrbitTrapLineImaginaryAxis presets are well-formed', () {
    final m = F1161OrbitTrapLineImaginaryAxis();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1161OrbitTrapLineImaginaryAxis metadata is consistent', () {
    final m = F1161OrbitTrapLineImaginaryAxis();
    expect(m.metadata.id, m.id);
  });
}
