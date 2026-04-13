// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0192_maze_julia/f0192_maze_julia_module.dart';

void main() {
  test('F0192MazeJulia instantiates', () {
    final m = F0192MazeJulia();
    expect(m.id, 'f0192_maze_julia');
    expect(m.shader, 'shaders/f0192_maze_julia_gpu.frag');
  });

  test('F0192MazeJulia presets are well-formed', () {
    final m = F0192MazeJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0192MazeJulia metadata is consistent', () {
    final m = F0192MazeJulia();
    expect(m.metadata.id, m.id);
  });
}
