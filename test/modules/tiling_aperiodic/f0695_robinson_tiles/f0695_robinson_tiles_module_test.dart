// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0695_robinson_tiles/f0695_robinson_tiles_module.dart';

void main() {
  test('F0695RobinsonTiles instantiates', () {
    final m = F0695RobinsonTiles();
    expect(m.id, 'f0695_robinson_tiles');
    expect(m.shader, 'shaders/f0695_robinson_tiles_gpu.frag');
  });

  test('F0695RobinsonTiles presets are well-formed', () {
    final m = F0695RobinsonTiles();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0695RobinsonTiles metadata is consistent', () {
    final m = F0695RobinsonTiles();
    expect(m.metadata.id, m.id);
  });
}
