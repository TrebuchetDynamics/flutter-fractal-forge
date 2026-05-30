// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1080_tinkerbell_ring/f1080_tinkerbell_ring_module.dart';

void main() {
  test('F1080TinkerbellRing instantiates', () {
    final m = F1080TinkerbellRing();
    expect(m.id, 'f1080_tinkerbell_ring');
    expect(m.shader, 'shaders/f1080_tinkerbell_ring_gpu.frag');
  });

  test('F1080TinkerbellRing presets are well-formed', () {
    final m = F1080TinkerbellRing();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1080TinkerbellRing metadata is consistent', () {
    final m = F1080TinkerbellRing();
    expect(m.metadata.id, m.id);
  });
}
