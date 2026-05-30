// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0211_ikeda_map/f0211_ikeda_map_module.dart';

void main() {
  test('F0211IkedaMap instantiates', () {
    final m = F0211IkedaMap();
    expect(m.id, 'f0211_ikeda_map');
    expect(m.shader, 'shaders/f0211_ikeda_map_gpu.frag');
  });

  test('F0211IkedaMap presets are well-formed', () {
    final m = F0211IkedaMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0211IkedaMap metadata is consistent', () {
    final m = F0211IkedaMap();
    expect(m.metadata.id, m.id);
  });
}
