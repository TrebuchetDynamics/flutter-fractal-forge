// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0128_cauliflower_period_3_bulb/f0128_cauliflower_period_3_bulb_module.dart';

void main() {
  test('F0128CauliflowerPeriod3Bulb instantiates', () {
    final m = F0128CauliflowerPeriod3Bulb();
    expect(m.id, 'f0128_cauliflower_period_3_bulb');
    expect(m.shader, 'shaders/f0128_cauliflower_period_3_bulb_gpu.frag');
  });

  test('F0128CauliflowerPeriod3Bulb presets are well-formed', () {
    final m = F0128CauliflowerPeriod3Bulb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0128CauliflowerPeriod3Bulb metadata is consistent', () {
    final m = F0128CauliflowerPeriod3Bulb();
    expect(m.metadata.id, m.id);
  });
}
