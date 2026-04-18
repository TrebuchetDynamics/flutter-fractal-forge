// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1170_orbit_trap_lima_on/f1170_orbit_trap_lima_on_module.dart';

void main() {
  test('F1170OrbitTrapLimaOn instantiates', () {
    final m = F1170OrbitTrapLimaOn();
    expect(m.id, 'f1170_orbit_trap_lima_on');
    expect(m.shader, 'shaders/f1170_orbit_trap_lima_on_gpu.frag');
  });

  test('F1170OrbitTrapLimaOn presets are well-formed', () {
    final m = F1170OrbitTrapLimaOn();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1170OrbitTrapLimaOn metadata is consistent', () {
    final m = F1170OrbitTrapLimaOn();
    expect(m.metadata.id, m.id);
  });
}
