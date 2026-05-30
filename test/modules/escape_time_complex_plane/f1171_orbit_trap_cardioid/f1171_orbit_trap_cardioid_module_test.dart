// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1171_orbit_trap_cardioid/f1171_orbit_trap_cardioid_module.dart';

void main() {
  test('F1171OrbitTrapCardioid instantiates', () {
    final m = F1171OrbitTrapCardioid();
    expect(m.id, 'f1171_orbit_trap_cardioid');
    expect(m.shader, 'shaders/f1171_orbit_trap_cardioid_gpu.frag');
  });

  test('F1171OrbitTrapCardioid presets are well-formed', () {
    final m = F1171OrbitTrapCardioid();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1171OrbitTrapCardioid metadata is consistent', () {
    final m = F1171OrbitTrapCardioid();
    expect(m.metadata.id, m.id);
  });
}
