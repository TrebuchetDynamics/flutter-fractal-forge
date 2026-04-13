// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0272_koch_curve_ifs/f0272_koch_curve_ifs_module.dart';

void main() {
  test('F0272KochCurveIfs instantiates', () {
    final m = F0272KochCurveIfs();
    expect(m.id, 'f0272_koch_curve_ifs');
    expect(m.shader, 'shaders/f0272_koch_curve_ifs_gpu.frag');
  });

  test('F0272KochCurveIfs presets are well-formed', () {
    final m = F0272KochCurveIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0272KochCurveIfs metadata is consistent', () {
    final m = F0272KochCurveIfs();
    expect(m.metadata.id, m.id);
  });
}
