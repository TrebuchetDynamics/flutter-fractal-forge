// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0331_lenia_orbium/f0331_lenia_orbium_module.dart';

void main() {
  test('F0331LeniaOrbium instantiates', () {
    final m = F0331LeniaOrbium();
    expect(m.id, 'f0331_lenia_orbium');
    expect(m.shader, 'shaders/f0331_lenia_orbium_gpu.frag');
  });

  test('F0331LeniaOrbium presets are well-formed', () {
    final m = F0331LeniaOrbium();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0331LeniaOrbium metadata is consistent', () {
    final m = F0331LeniaOrbium();
    expect(m.metadata.id, m.id);
  });
}
