// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0214_zaslavskii_map/f0214_zaslavskii_map_module.dart';

void main() {
  test('F0214ZaslavskiiMap instantiates', () {
    final m = F0214ZaslavskiiMap();
    expect(m.id, 'f0214_zaslavskii_map');
    expect(m.shader, 'shaders/f0214_zaslavskii_map_gpu.frag');
  });

  test('F0214ZaslavskiiMap presets are well-formed', () {
    final m = F0214ZaslavskiiMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0214ZaslavskiiMap metadata is consistent', () {
    final m = F0214ZaslavskiiMap();
    expect(m.metadata.id, m.id);
  });
}
