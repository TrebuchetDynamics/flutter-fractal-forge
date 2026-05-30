// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1005_maze_with_mice_b37_s12345/f1005_maze_with_mice_b37_s12345_module.dart';

void main() {
  test('F1005MazeWithMiceB37S12345 instantiates', () {
    final m = F1005MazeWithMiceB37S12345();
    expect(m.id, 'f1005_maze_with_mice_b37_s12345');
    expect(m.shader, 'shaders/f1005_maze_with_mice_b37_s12345_gpu.frag');
  });

  test('F1005MazeWithMiceB37S12345 presets are well-formed', () {
    final m = F1005MazeWithMiceB37S12345();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1005MazeWithMiceB37S12345 metadata is consistent', () {
    final m = F1005MazeWithMiceB37S12345();
    expect(m.metadata.id, m.id);
  });
}
