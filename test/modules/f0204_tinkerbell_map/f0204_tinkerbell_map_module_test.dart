// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0204_tinkerbell_map/f0204_tinkerbell_map_module.dart';

void main() {
  test('F0204TinkerbellMap instantiates', () {
    final m = F0204TinkerbellMap();
    expect(m.id, 'f0204_tinkerbell_map');
    expect(m.shader, 'shaders/f0204_tinkerbell_map_gpu.frag');
  });

  test('F0204TinkerbellMap presets are well-formed', () {
    final m = F0204TinkerbellMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0204TinkerbellMap metadata is consistent', () {
    final m = F0204TinkerbellMap();
    expect(m.metadata.id, m.id);
  });
}
