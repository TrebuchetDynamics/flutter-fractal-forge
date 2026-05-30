// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0809_doubling_map/f0809_doubling_map_module.dart';

void main() {
  test('F0809DoublingMap instantiates', () {
    final m = F0809DoublingMap();
    expect(m.id, 'f0809_doubling_map');
    expect(m.shader, 'shaders/f0809_doubling_map_gpu.frag');
  });

  test('F0809DoublingMap presets are well-formed', () {
    final m = F0809DoublingMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0809DoublingMap metadata is consistent', () {
    final m = F0809DoublingMap();
    expect(m.metadata.id, m.id);
  });
}
