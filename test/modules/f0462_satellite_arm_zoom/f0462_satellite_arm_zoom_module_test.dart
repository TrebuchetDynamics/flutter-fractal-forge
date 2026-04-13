// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0462_satellite_arm_zoom/f0462_satellite_arm_zoom_module.dart';

void main() {
  test('F0462SatelliteArmZoom instantiates', () {
    final m = F0462SatelliteArmZoom();
    expect(m.id, 'f0462_satellite_arm_zoom');
    expect(m.shader, 'shaders/f0462_satellite_arm_zoom_gpu.frag');
  });

  test('F0462SatelliteArmZoom presets are well-formed', () {
    final m = F0462SatelliteArmZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0462SatelliteArmZoom metadata is consistent', () {
    final m = F0462SatelliteArmZoom();
    expect(m.metadata.id, m.id);
  });
}
