// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1078_tinkerbell_distorted/f1078_tinkerbell_distorted_module.dart';

void main() {
  test('F1078TinkerbellDistorted instantiates', () {
    final m = F1078TinkerbellDistorted();
    expect(m.id, 'f1078_tinkerbell_distorted');
    expect(m.shader, 'shaders/f1078_tinkerbell_distorted_gpu.frag');
  });

  test('F1078TinkerbellDistorted presets are well-formed', () {
    final m = F1078TinkerbellDistorted();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1078TinkerbellDistorted metadata is consistent', () {
    final m = F1078TinkerbellDistorted();
    expect(m.metadata.id, m.id);
  });
}
