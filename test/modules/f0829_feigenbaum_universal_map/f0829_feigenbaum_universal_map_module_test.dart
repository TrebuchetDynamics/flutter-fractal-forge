// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0829_feigenbaum_universal_map/f0829_feigenbaum_universal_map_module.dart';

void main() {
  test('F0829FeigenbaumUniversalMap instantiates', () {
    final m = F0829FeigenbaumUniversalMap();
    expect(m.id, 'f0829_feigenbaum_universal_map');
    expect(m.shader, 'shaders/f0829_feigenbaum_universal_map_gpu.frag');
  });

  test('F0829FeigenbaumUniversalMap presets are well-formed', () {
    final m = F0829FeigenbaumUniversalMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0829FeigenbaumUniversalMap metadata is consistent', () {
    final m = F0829FeigenbaumUniversalMap();
    expect(m.metadata.id, m.id);
  });
}
