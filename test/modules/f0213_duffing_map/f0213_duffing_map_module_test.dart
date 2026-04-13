// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0213_duffing_map/f0213_duffing_map_module.dart';

void main() {
  test('F0213DuffingMap instantiates', () {
    final m = F0213DuffingMap();
    expect(m.id, 'f0213_duffing_map');
    expect(m.shader, 'shaders/f0213_duffing_map_gpu.frag');
  });

  test('F0213DuffingMap presets are well-formed', () {
    final m = F0213DuffingMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0213DuffingMap metadata is consistent', () {
    final m = F0213DuffingMap();
    expect(m.metadata.id, m.id);
  });
}
