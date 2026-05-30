// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1177_orbit_trap_field_lines/f1177_orbit_trap_field_lines_module.dart';

void main() {
  test('F1177OrbitTrapFieldLines instantiates', () {
    final m = F1177OrbitTrapFieldLines();
    expect(m.id, 'f1177_orbit_trap_field_lines');
    expect(m.shader, 'shaders/f1177_orbit_trap_field_lines_gpu.frag');
  });

  test('F1177OrbitTrapFieldLines presets are well-formed', () {
    final m = F1177OrbitTrapFieldLines();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1177OrbitTrapFieldLines metadata is consistent', () {
    final m = F1177OrbitTrapFieldLines();
    expect(m.metadata.id, m.id);
  });
}
