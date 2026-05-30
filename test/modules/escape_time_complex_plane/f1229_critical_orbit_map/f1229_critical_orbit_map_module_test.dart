// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1229_critical_orbit_map/f1229_critical_orbit_map_module.dart';

void main() {
  test('F1229CriticalOrbitMap instantiates', () {
    final m = F1229CriticalOrbitMap();
    expect(m.id, 'f1229_critical_orbit_map');
    expect(m.shader, 'shaders/f1229_critical_orbit_map_gpu.frag');
  });

  test('F1229CriticalOrbitMap presets are well-formed', () {
    final m = F1229CriticalOrbitMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1229CriticalOrbitMap metadata is consistent', () {
    final m = F1229CriticalOrbitMap();
    expect(m.metadata.id, m.id);
  });
}
