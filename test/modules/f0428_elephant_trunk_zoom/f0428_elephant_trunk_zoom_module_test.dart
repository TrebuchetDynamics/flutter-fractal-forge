// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0428_elephant_trunk_zoom/f0428_elephant_trunk_zoom_module.dart';

void main() {
  test('F0428ElephantTrunkZoom instantiates', () {
    final m = F0428ElephantTrunkZoom();
    expect(m.id, 'f0428_elephant_trunk_zoom');
    expect(m.shader, 'shaders/f0428_elephant_trunk_zoom_gpu.frag');
  });

  test('F0428ElephantTrunkZoom presets are well-formed', () {
    final m = F0428ElephantTrunkZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0428ElephantTrunkZoom metadata is consistent', () {
    final m = F0428ElephantTrunkZoom();
    expect(m.metadata.id, m.id);
  });
}
