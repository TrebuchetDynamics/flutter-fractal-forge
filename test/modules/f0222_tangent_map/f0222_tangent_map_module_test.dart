// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0222_tangent_map/f0222_tangent_map_module.dart';

void main() {
  test('F0222TangentMap instantiates', () {
    final m = F0222TangentMap();
    expect(m.id, 'f0222_tangent_map');
    expect(m.shader, 'shaders/f0222_tangent_map_gpu.frag');
  });

  test('F0222TangentMap presets are well-formed', () {
    final m = F0222TangentMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0222TangentMap metadata is consistent', () {
    final m = F0222TangentMap();
    expect(m.metadata.id, m.id);
  });
}
