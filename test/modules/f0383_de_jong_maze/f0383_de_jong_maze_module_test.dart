// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0383_de_jong_maze/f0383_de_jong_maze_module.dart';

void main() {
  test('F0383DeJongMaze instantiates', () {
    final m = F0383DeJongMaze();
    expect(m.id, 'f0383_de_jong_maze');
    expect(m.shader, 'shaders/f0383_de_jong_maze_gpu.frag');
  });

  test('F0383DeJongMaze presets are well-formed', () {
    final m = F0383DeJongMaze();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0383DeJongMaze metadata is consistent', () {
    final m = F0383DeJongMaze();
    expect(m.metadata.id, m.id);
  });
}
