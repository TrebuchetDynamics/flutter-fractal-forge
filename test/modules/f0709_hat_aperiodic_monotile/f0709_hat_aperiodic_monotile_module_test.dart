// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0709_hat_aperiodic_monotile/f0709_hat_aperiodic_monotile_module.dart';

void main() {
  test('F0709HatAperiodicMonotile instantiates', () {
    final m = F0709HatAperiodicMonotile();
    expect(m.id, 'f0709_hat_aperiodic_monotile');
    expect(m.shader, 'shaders/f0709_hat_aperiodic_monotile_gpu.frag');
  });

  test('F0709HatAperiodicMonotile presets are well-formed', () {
    final m = F0709HatAperiodicMonotile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0709HatAperiodicMonotile metadata is consistent', () {
    final m = F0709HatAperiodicMonotile();
    expect(m.metadata.id, m.id);
  });
}
