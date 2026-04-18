// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0825_arnold_cat_map/f0825_arnold_cat_map_module.dart';

void main() {
  test('F0825ArnoldCatMap instantiates', () {
    final m = F0825ArnoldCatMap();
    expect(m.id, 'f0825_arnold_cat_map');
    expect(m.shader, 'shaders/f0825_arnold_cat_map_gpu.frag');
  });

  test('F0825ArnoldCatMap presets are well-formed', () {
    final m = F0825ArnoldCatMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0825ArnoldCatMap metadata is consistent', () {
    final m = F0825ArnoldCatMap();
    expect(m.metadata.id, m.id);
  });
}
