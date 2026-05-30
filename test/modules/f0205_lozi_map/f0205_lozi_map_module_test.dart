// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0205_lozi_map/f0205_lozi_map_module.dart';

void main() {
  test('F0205LoziMap instantiates', () {
    final m = F0205LoziMap();
    expect(m.id, 'f0205_lozi_map');
    expect(m.shader, 'shaders/f0205_lozi_map_gpu.frag');
  });

  test('F0205LoziMap presets are well-formed', () {
    final m = F0205LoziMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0205LoziMap metadata is consistent', () {
    final m = F0205LoziMap();
    expect(m.metadata.id, m.id);
  });
}
