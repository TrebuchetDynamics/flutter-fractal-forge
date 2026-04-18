// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1162_orbit_trap_multi_lines_cross/f1162_orbit_trap_multi_lines_cross_module.dart';

void main() {
  test('F1162OrbitTrapMultiLinesCross instantiates', () {
    final m = F1162OrbitTrapMultiLinesCross();
    expect(m.id, 'f1162_orbit_trap_multi_lines_cross');
    expect(m.shader, 'shaders/f1162_orbit_trap_multi_lines_cross_gpu.frag');
  });

  test('F1162OrbitTrapMultiLinesCross presets are well-formed', () {
    final m = F1162OrbitTrapMultiLinesCross();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1162OrbitTrapMultiLinesCross metadata is consistent', () {
    final m = F1162OrbitTrapMultiLinesCross();
    expect(m.metadata.id, m.id);
  });
}
