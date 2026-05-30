// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1077_tinkerbell_classic/f1077_tinkerbell_classic_module.dart';

void main() {
  test('F1077TinkerbellClassic instantiates', () {
    final m = F1077TinkerbellClassic();
    expect(m.id, 'f1077_tinkerbell_classic');
    expect(m.shader, 'shaders/f1077_tinkerbell_classic_gpu.frag');
  });

  test('F1077TinkerbellClassic presets are well-formed', () {
    final m = F1077TinkerbellClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1077TinkerbellClassic metadata is consistent', () {
    final m = F1077TinkerbellClassic();
    expect(m.metadata.id, m.id);
  });
}
