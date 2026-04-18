// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0710_turtle_aperiodic_monotile/f0710_turtle_aperiodic_monotile_module.dart';

void main() {
  test('F0710TurtleAperiodicMonotile instantiates', () {
    final m = F0710TurtleAperiodicMonotile();
    expect(m.id, 'f0710_turtle_aperiodic_monotile');
    expect(m.shader, 'shaders/f0710_turtle_aperiodic_monotile_gpu.frag');
  });

  test('F0710TurtleAperiodicMonotile presets are well-formed', () {
    final m = F0710TurtleAperiodicMonotile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0710TurtleAperiodicMonotile metadata is consistent', () {
    final m = F0710TurtleAperiodicMonotile();
    expect(m.metadata.id, m.id);
  });
}
