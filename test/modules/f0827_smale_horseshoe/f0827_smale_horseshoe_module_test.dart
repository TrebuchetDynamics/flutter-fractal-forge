// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0827_smale_horseshoe/f0827_smale_horseshoe_module.dart';

void main() {
  test('F0827SmaleHorseshoe instantiates', () {
    final m = F0827SmaleHorseshoe();
    expect(m.id, 'f0827_smale_horseshoe');
    expect(m.shader, 'shaders/f0827_smale_horseshoe_gpu.frag');
  });

  test('F0827SmaleHorseshoe presets are well-formed', () {
    final m = F0827SmaleHorseshoe();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0827SmaleHorseshoe metadata is consistent', () {
    final m = F0827SmaleHorseshoe();
    expect(m.metadata.id, m.id);
  });
}
