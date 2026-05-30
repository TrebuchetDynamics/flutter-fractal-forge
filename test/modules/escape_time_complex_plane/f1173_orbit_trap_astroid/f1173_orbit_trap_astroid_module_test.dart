// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1173_orbit_trap_astroid/f1173_orbit_trap_astroid_module.dart';

void main() {
  test('F1173OrbitTrapAstroid instantiates', () {
    final m = F1173OrbitTrapAstroid();
    expect(m.id, 'f1173_orbit_trap_astroid');
    expect(m.shader, 'shaders/f1173_orbit_trap_astroid_gpu.frag');
  });

  test('F1173OrbitTrapAstroid presets are well-formed', () {
    final m = F1173OrbitTrapAstroid();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1173OrbitTrapAstroid metadata is consistent', () {
    final m = F1173OrbitTrapAstroid();
    expect(m.metadata.id, m.id);
  });
}
