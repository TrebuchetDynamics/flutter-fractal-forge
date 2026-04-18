// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0712_t_tile_tetromino_aperiodic/f0712_t_tile_tetromino_aperiodic_module.dart';

void main() {
  test('F0712TTileTetrominoAperiodic instantiates', () {
    final m = F0712TTileTetrominoAperiodic();
    expect(m.id, 'f0712_t_tile_tetromino_aperiodic');
    expect(m.shader, 'shaders/f0712_t_tile_tetromino_aperiodic_gpu.frag');
  });

  test('F0712TTileTetrominoAperiodic presets are well-formed', () {
    final m = F0712TTileTetrominoAperiodic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0712TTileTetrominoAperiodic metadata is consistent', () {
    final m = F0712TTileTetrominoAperiodic();
    expect(m.metadata.id, m.id);
  });
}
