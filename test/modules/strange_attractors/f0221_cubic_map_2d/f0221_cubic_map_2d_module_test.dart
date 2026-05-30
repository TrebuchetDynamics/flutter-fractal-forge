// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0221_cubic_map_2d/f0221_cubic_map_2d_module.dart';

void main() {
  test('F0221CubicMap2d instantiates', () {
    final m = F0221CubicMap2d();
    expect(m.id, 'f0221_cubic_map_2d');
    expect(m.shader, 'shaders/f0221_cubic_map_2d_gpu.frag');
  });

  test('F0221CubicMap2d presets are well-formed', () {
    final m = F0221CubicMap2d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0221CubicMap2d metadata is consistent', () {
    final m = F0221CubicMap2d();
    expect(m.metadata.id, m.id);
  });
}
