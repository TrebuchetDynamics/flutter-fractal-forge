// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0473_spiral_galaxy_zoom/f0473_spiral_galaxy_zoom_module.dart';

void main() {
  test('F0473SpiralGalaxyZoom instantiates', () {
    final m = F0473SpiralGalaxyZoom();
    expect(m.id, 'f0473_spiral_galaxy_zoom');
    expect(m.shader, 'shaders/f0473_spiral_galaxy_zoom_gpu.frag');
  });

  test('F0473SpiralGalaxyZoom presets are well-formed', () {
    final m = F0473SpiralGalaxyZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0473SpiralGalaxyZoom metadata is consistent', () {
    final m = F0473SpiralGalaxyZoom();
    expect(m.metadata.id, m.id);
  });
}
