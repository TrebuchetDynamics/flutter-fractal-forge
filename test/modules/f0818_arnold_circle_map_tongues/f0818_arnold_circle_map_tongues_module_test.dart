// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0818_arnold_circle_map_tongues/f0818_arnold_circle_map_tongues_module.dart';

void main() {
  test('F0818ArnoldCircleMapTongues instantiates', () {
    final m = F0818ArnoldCircleMapTongues();
    expect(m.id, 'f0818_arnold_circle_map_tongues');
    expect(m.shader, 'shaders/f0818_arnold_circle_map_tongues_gpu.frag');
  });

  test('F0818ArnoldCircleMapTongues presets are well-formed', () {
    final m = F0818ArnoldCircleMapTongues();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0818ArnoldCircleMapTongues metadata is consistent', () {
    final m = F0818ArnoldCircleMapTongues();
    expect(m.metadata.id, m.id);
  });
}
