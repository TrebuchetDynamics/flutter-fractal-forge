// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0030_sprott_q/f0030_sprott_q_module.dart';

void main() {
  test('F0030SprottQ instantiates', () {
    final m = F0030SprottQ();
    expect(m.id, 'f0030_sprott_q');
    expect(m.shader, 'shaders/f0030_sprott_q_gpu.frag');
  });

  test('F0030SprottQ presets are well-formed', () {
    final m = F0030SprottQ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0030SprottQ metadata is consistent', () {
    final m = F0030SprottQ();
    expect(m.metadata.id, m.id);
  });
}
