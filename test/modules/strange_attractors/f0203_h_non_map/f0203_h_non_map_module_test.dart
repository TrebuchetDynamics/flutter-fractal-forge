// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0203_h_non_map/f0203_h_non_map_module.dart';

void main() {
  test('F0203HNonMap instantiates', () {
    final m = F0203HNonMap();
    expect(m.id, 'f0203_h_non_map');
    expect(m.shader, 'shaders/f0203_h_non_map_gpu.frag');
  });

  test('F0203HNonMap presets are well-formed', () {
    final m = F0203HNonMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0203HNonMap metadata is consistent', () {
    final m = F0203HNonMap();
    expect(m.metadata.id, m.id);
  });
}
