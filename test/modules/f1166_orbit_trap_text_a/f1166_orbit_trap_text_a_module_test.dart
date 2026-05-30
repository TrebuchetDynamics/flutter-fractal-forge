// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1166_orbit_trap_text_a/f1166_orbit_trap_text_a_module.dart';

void main() {
  test('F1166OrbitTrapTextA instantiates', () {
    final m = F1166OrbitTrapTextA();
    expect(m.id, 'f1166_orbit_trap_text_a');
    expect(m.shader, 'shaders/f1166_orbit_trap_text_a_gpu.frag');
  });

  test('F1166OrbitTrapTextA presets are well-formed', () {
    final m = F1166OrbitTrapTextA();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1166OrbitTrapTextA metadata is consistent', () {
    final m = F1166OrbitTrapTextA();
    expect(m.metadata.id, m.id);
  });
}
