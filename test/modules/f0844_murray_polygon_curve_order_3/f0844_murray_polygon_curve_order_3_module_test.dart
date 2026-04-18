// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0844_murray_polygon_curve_order_3/f0844_murray_polygon_curve_order_3_module.dart';

void main() {
  test('F0844MurrayPolygonCurveOrder3 instantiates', () {
    final m = F0844MurrayPolygonCurveOrder3();
    expect(m.id, 'f0844_murray_polygon_curve_order_3');
    expect(m.shader, 'shaders/f0844_murray_polygon_curve_order_3_gpu.frag');
  });

  test('F0844MurrayPolygonCurveOrder3 presets are well-formed', () {
    final m = F0844MurrayPolygonCurveOrder3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0844MurrayPolygonCurveOrder3 metadata is consistent', () {
    final m = F0844MurrayPolygonCurveOrder3();
    expect(m.metadata.id, m.id);
  });
}
