// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1178_orbit_trap_composite_multi_shape/f1178_orbit_trap_composite_multi_shape_module.dart';

void main() {
  test('F1178OrbitTrapCompositeMultiShape instantiates', () {
    final m = F1178OrbitTrapCompositeMultiShape();
    expect(m.id, 'f1178_orbit_trap_composite_multi_shape');
    expect(m.shader, 'shaders/f1178_orbit_trap_composite_multi_shape_gpu.frag');
  });

  test('F1178OrbitTrapCompositeMultiShape presets are well-formed', () {
    final m = F1178OrbitTrapCompositeMultiShape();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1178OrbitTrapCompositeMultiShape metadata is consistent', () {
    final m = F1178OrbitTrapCompositeMultiShape();
    expect(m.metadata.id, m.id);
  });
}
