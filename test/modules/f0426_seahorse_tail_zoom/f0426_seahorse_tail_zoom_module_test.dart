// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0426_seahorse_tail_zoom/f0426_seahorse_tail_zoom_module.dart';

void main() {
  test('F0426SeahorseTailZoom instantiates', () {
    final m = F0426SeahorseTailZoom();
    expect(m.id, 'f0426_seahorse_tail_zoom');
    expect(m.shader, 'shaders/f0426_seahorse_tail_zoom_gpu.frag');
  });

  test('F0426SeahorseTailZoom presets are well-formed', () {
    final m = F0426SeahorseTailZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0426SeahorseTailZoom metadata is consistent', () {
    final m = F0426SeahorseTailZoom();
    expect(m.metadata.id, m.id);
  });
}
