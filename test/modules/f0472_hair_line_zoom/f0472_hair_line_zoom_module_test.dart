// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0472_hair_line_zoom/f0472_hair_line_zoom_module.dart';

void main() {
  test('F0472HairLineZoom instantiates', () {
    final m = F0472HairLineZoom();
    expect(m.id, 'f0472_hair_line_zoom');
    expect(m.shader, 'shaders/f0472_hair_line_zoom_gpu.frag');
  });

  test('F0472HairLineZoom presets are well-formed', () {
    final m = F0472HairLineZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0472HairLineZoom metadata is consistent', () {
    final m = F0472HairLineZoom();
    expect(m.metadata.id, m.id);
  });
}
