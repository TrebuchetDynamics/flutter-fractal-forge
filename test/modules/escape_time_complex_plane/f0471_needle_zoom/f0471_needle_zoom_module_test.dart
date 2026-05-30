// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0471_needle_zoom/f0471_needle_zoom_module.dart';

void main() {
  test('F0471NeedleZoom instantiates', () {
    final m = F0471NeedleZoom();
    expect(m.id, 'f0471_needle_zoom');
    expect(m.shader, 'shaders/f0471_needle_zoom_gpu.frag');
  });

  test('F0471NeedleZoom presets are well-formed', () {
    final m = F0471NeedleZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0471NeedleZoom metadata is consistent', () {
    final m = F0471NeedleZoom();
    expect(m.metadata.id, m.id);
  });
}
