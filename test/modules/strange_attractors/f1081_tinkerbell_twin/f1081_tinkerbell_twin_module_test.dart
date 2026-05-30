// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1081_tinkerbell_twin/f1081_tinkerbell_twin_module.dart';

void main() {
  test('F1081TinkerbellTwin instantiates', () {
    final m = F1081TinkerbellTwin();
    expect(m.id, 'f1081_tinkerbell_twin');
    expect(m.shader, 'shaders/f1081_tinkerbell_twin_gpu.frag');
  });

  test('F1081TinkerbellTwin presets are well-formed', () {
    final m = F1081TinkerbellTwin();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1081TinkerbellTwin metadata is consistent', () {
    final m = F1081TinkerbellTwin();
    expect(m.metadata.id, m.id);
  });
}
