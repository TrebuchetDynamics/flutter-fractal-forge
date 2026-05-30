// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1156_orbit_trap_cross/f1156_orbit_trap_cross_module.dart';

void main() {
  test('F1156OrbitTrapCross instantiates', () {
    final m = F1156OrbitTrapCross();
    expect(m.id, 'f1156_orbit_trap_cross');
    expect(m.shader, 'shaders/f1156_orbit_trap_cross_gpu.frag');
  });

  test('F1156OrbitTrapCross presets are well-formed', () {
    final m = F1156OrbitTrapCross();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1156OrbitTrapCross metadata is consistent', () {
    final m = F1156OrbitTrapCross();
    expect(m.metadata.id, m.id);
  });
}
