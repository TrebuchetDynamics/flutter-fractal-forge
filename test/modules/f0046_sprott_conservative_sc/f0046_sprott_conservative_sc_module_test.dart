// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0046_sprott_conservative_sc/f0046_sprott_conservative_sc_module.dart';

void main() {
  test('F0046SprottConservativeSc instantiates', () {
    final m = F0046SprottConservativeSc();
    expect(m.id, 'f0046_sprott_conservative_sc');
    expect(m.shader, 'shaders/f0046_sprott_conservative_sc_gpu.frag');
  });

  test('F0046SprottConservativeSc presets are well-formed', () {
    final m = F0046SprottConservativeSc();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0046SprottConservativeSc metadata is consistent', () {
    final m = F0046SprottConservativeSc();
    expect(m.metadata.id, m.id);
  });
}
