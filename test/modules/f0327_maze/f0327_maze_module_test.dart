// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0327_maze/f0327_maze_module.dart';

void main() {
  test('F0327Maze instantiates', () {
    final m = F0327Maze();
    expect(m.id, 'f0327_maze');
    expect(m.shader, 'shaders/f0327_maze_gpu.frag');
  });

  test('F0327Maze presets are well-formed', () {
    final m = F0327Maze();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0327Maze metadata is consistent', () {
    final m = F0327Maze();
    expect(m.metadata.id, m.id);
  });
}
