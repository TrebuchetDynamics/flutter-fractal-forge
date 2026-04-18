// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1157_orbit_trap_square/f1157_orbit_trap_square_module.dart';

void main() {
  test('F1157OrbitTrapSquare instantiates', () {
    final m = F1157OrbitTrapSquare();
    expect(m.id, 'f1157_orbit_trap_square');
    expect(m.shader, 'shaders/f1157_orbit_trap_square_gpu.frag');
  });

  test('F1157OrbitTrapSquare presets are well-formed', () {
    final m = F1157OrbitTrapSquare();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1157OrbitTrapSquare metadata is consistent', () {
    final m = F1157OrbitTrapSquare();
    expect(m.metadata.id, m.id);
  });
}
