// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1008_honey_life_b38_s238/f1008_honey_life_b38_s238_module.dart';

void main() {
  test('F1008HoneyLifeB38S238 instantiates', () {
    final m = F1008HoneyLifeB38S238();
    expect(m.id, 'f1008_honey_life_b38_s238');
    expect(m.shader, 'shaders/f1008_honey_life_b38_s238_gpu.frag');
  });

  test('F1008HoneyLifeB38S238 presets are well-formed', () {
    final m = F1008HoneyLifeB38S238();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1008HoneyLifeB38S238 metadata is consistent', () {
    final m = F1008HoneyLifeB38S238();
    expect(m.metadata.id, m.id);
  });
}
