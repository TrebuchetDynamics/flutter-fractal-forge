// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0831_cubic_map_real/f0831_cubic_map_real_module.dart';

void main() {
  test('F0831CubicMapReal instantiates', () {
    final m = F0831CubicMapReal();
    expect(m.id, 'f0831_cubic_map_real');
    expect(m.shader, 'shaders/f0831_cubic_map_real_gpu.frag');
  });

  test('F0831CubicMapReal presets are well-formed', () {
    final m = F0831CubicMapReal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0831CubicMapReal metadata is consistent', () {
    final m = F0831CubicMapReal();
    expect(m.metadata.id, m.id);
  });
}
