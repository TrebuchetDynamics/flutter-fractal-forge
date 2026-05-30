// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0820_lotka_volterra_discrete/f0820_lotka_volterra_discrete_module.dart';

void main() {
  test('F0820LotkaVolterraDiscrete instantiates', () {
    final m = F0820LotkaVolterraDiscrete();
    expect(m.id, 'f0820_lotka_volterra_discrete');
    expect(m.shader, 'shaders/f0820_lotka_volterra_discrete_gpu.frag');
  });

  test('F0820LotkaVolterraDiscrete presets are well-formed', () {
    final m = F0820LotkaVolterraDiscrete();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0820LotkaVolterraDiscrete metadata is consistent', () {
    final m = F0820LotkaVolterraDiscrete();
    expect(m.metadata.id, m.id);
  });
}
