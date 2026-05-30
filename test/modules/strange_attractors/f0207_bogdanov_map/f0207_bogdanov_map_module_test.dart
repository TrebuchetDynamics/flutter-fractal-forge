// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0207_bogdanov_map/f0207_bogdanov_map_module.dart';

void main() {
  test('F0207BogdanovMap instantiates', () {
    final m = F0207BogdanovMap();
    expect(m.id, 'f0207_bogdanov_map');
    expect(m.shader, 'shaders/f0207_bogdanov_map_gpu.frag');
  });

  test('F0207BogdanovMap presets are well-formed', () {
    final m = F0207BogdanovMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0207BogdanovMap metadata is consistent', () {
    final m = F0207BogdanovMap();
    expect(m.metadata.id, m.id);
  });
}
