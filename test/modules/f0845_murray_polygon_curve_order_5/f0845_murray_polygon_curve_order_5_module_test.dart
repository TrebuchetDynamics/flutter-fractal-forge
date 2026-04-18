// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0845_murray_polygon_curve_order_5/f0845_murray_polygon_curve_order_5_module.dart';

void main() {
  test('F0845MurrayPolygonCurveOrder5 instantiates', () {
    final m = F0845MurrayPolygonCurveOrder5();
    expect(m.id, 'f0845_murray_polygon_curve_order_5');
    expect(m.shader, 'shaders/f0845_murray_polygon_curve_order_5_gpu.frag');
  });

  test('F0845MurrayPolygonCurveOrder5 presets are well-formed', () {
    final m = F0845MurrayPolygonCurveOrder5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0845MurrayPolygonCurveOrder5 metadata is consistent', () {
    final m = F0845MurrayPolygonCurveOrder5();
    expect(m.metadata.id, m.id);
  });
}
