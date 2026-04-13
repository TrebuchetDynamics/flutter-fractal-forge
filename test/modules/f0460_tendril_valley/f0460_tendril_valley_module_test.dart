// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0460_tendril_valley/f0460_tendril_valley_module.dart';

void main() {
  test('F0460TendrilValley instantiates', () {
    final m = F0460TendrilValley();
    expect(m.id, 'f0460_tendril_valley');
    expect(m.shader, 'shaders/f0460_tendril_valley_gpu.frag');
  });

  test('F0460TendrilValley presets are well-formed', () {
    final m = F0460TendrilValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0460TendrilValley metadata is consistent', () {
    final m = F0460TendrilValley();
    expect(m.metadata.id, m.id);
  });
}
