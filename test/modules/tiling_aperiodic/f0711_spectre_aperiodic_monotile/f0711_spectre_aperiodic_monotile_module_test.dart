// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0711_spectre_aperiodic_monotile/f0711_spectre_aperiodic_monotile_module.dart';

void main() {
  test('F0711SpectreAperiodicMonotile instantiates', () {
    final m = F0711SpectreAperiodicMonotile();
    expect(m.id, 'f0711_spectre_aperiodic_monotile');
    expect(m.shader, 'shaders/f0711_spectre_aperiodic_monotile_gpu.frag');
  });

  test('F0711SpectreAperiodicMonotile presets are well-formed', () {
    final m = F0711SpectreAperiodicMonotile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0711SpectreAperiodicMonotile metadata is consistent', () {
    final m = F0711SpectreAperiodicMonotile();
    expect(m.metadata.id, m.id);
  });
}
