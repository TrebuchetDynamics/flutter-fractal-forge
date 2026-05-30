// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1079_tinkerbell_wing/f1079_tinkerbell_wing_module.dart';

void main() {
  test('F1079TinkerbellWing instantiates', () {
    final m = F1079TinkerbellWing();
    expect(m.id, 'f1079_tinkerbell_wing');
    expect(m.shader, 'shaders/f1079_tinkerbell_wing_gpu.frag');
  });

  test('F1079TinkerbellWing presets are well-formed', () {
    final m = F1079TinkerbellWing();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1079TinkerbellWing metadata is consistent', () {
    final m = F1079TinkerbellWing();
    expect(m.metadata.id, m.id);
  });
}
