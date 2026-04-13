// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0225_quadratic_koch_curve_type_1/f0225_quadratic_koch_curve_type_1_module.dart';

void main() {
  test('F0225QuadraticKochCurveType1 instantiates', () {
    final m = F0225QuadraticKochCurveType1();
    expect(m.id, 'f0225_quadratic_koch_curve_type_1');
    expect(m.shader, 'shaders/f0225_quadratic_koch_curve_type_1_gpu.frag');
  });

  test('F0225QuadraticKochCurveType1 presets are well-formed', () {
    final m = F0225QuadraticKochCurveType1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0225QuadraticKochCurveType1 metadata is consistent', () {
    final m = F0225QuadraticKochCurveType1();
    expect(m.metadata.id, m.id);
  });
}
