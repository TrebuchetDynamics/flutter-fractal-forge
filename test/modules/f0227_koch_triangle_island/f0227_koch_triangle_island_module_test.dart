// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0227_koch_triangle_island/f0227_koch_triangle_island_module.dart';

void main() {
  test('F0227KochTriangleIsland instantiates', () {
    final m = F0227KochTriangleIsland();
    expect(m.id, 'f0227_koch_triangle_island');
    expect(m.shader, 'shaders/f0227_koch_triangle_island_gpu.frag');
  });

  test('F0227KochTriangleIsland presets are well-formed', () {
    final m = F0227KochTriangleIsland();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0227KochTriangleIsland metadata is consistent', () {
    final m = F0227KochTriangleIsland();
    expect(m.metadata.id, m.id);
  });
}
