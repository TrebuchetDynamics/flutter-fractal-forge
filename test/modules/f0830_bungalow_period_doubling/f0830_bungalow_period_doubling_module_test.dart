// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0830_bungalow_period_doubling/f0830_bungalow_period_doubling_module.dart';

void main() {
  test('F0830BungalowPeriodDoubling instantiates', () {
    final m = F0830BungalowPeriodDoubling();
    expect(m.id, 'f0830_bungalow_period_doubling');
    expect(m.shader, 'shaders/f0830_bungalow_period_doubling_gpu.frag');
  });

  test('F0830BungalowPeriodDoubling presets are well-formed', () {
    final m = F0830BungalowPeriodDoubling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0830BungalowPeriodDoubling metadata is consistent', () {
    final m = F0830BungalowPeriodDoubling();
    expect(m.metadata.id, m.id);
  });
}
