// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1155_orbit_trap_circle_pickover_stalks/f1155_orbit_trap_circle_pickover_stalks_module.dart';

void main() {
  test('F1155OrbitTrapCirclePickoverStalks instantiates', () {
    final m = F1155OrbitTrapCirclePickoverStalks();
    expect(m.id, 'f1155_orbit_trap_circle_pickover_stalks');
    expect(
        m.shader, 'shaders/f1155_orbit_trap_circle_pickover_stalks_gpu.frag');
  });

  test('F1155OrbitTrapCirclePickoverStalks presets are well-formed', () {
    final m = F1155OrbitTrapCirclePickoverStalks();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1155OrbitTrapCirclePickoverStalks metadata is consistent', () {
    final m = F1155OrbitTrapCirclePickoverStalks();
    expect(m.metadata.id, m.id);
  });
}
