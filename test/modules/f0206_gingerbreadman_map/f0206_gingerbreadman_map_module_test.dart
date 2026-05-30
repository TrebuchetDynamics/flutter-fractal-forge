// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0206_gingerbreadman_map/f0206_gingerbreadman_map_module.dart';

void main() {
  test('F0206GingerbreadmanMap instantiates', () {
    final m = F0206GingerbreadmanMap();
    expect(m.id, 'f0206_gingerbreadman_map');
    expect(m.shader, 'shaders/f0206_gingerbreadman_map_gpu.frag');
  });

  test('F0206GingerbreadmanMap presets are well-formed', () {
    final m = F0206GingerbreadmanMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0206GingerbreadmanMap metadata is consistent', () {
    final m = F0206GingerbreadmanMap();
    expect(m.metadata.id, m.id);
  });
}
