// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0703_rep_9_tile/f0703_rep_9_tile_module.dart';

void main() {
  test('F0703Rep9Tile instantiates', () {
    final m = F0703Rep9Tile();
    expect(m.id, 'f0703_rep_9_tile');
    expect(m.shader, 'shaders/f0703_rep_9_tile_gpu.frag');
  });

  test('F0703Rep9Tile presets are well-formed', () {
    final m = F0703Rep9Tile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0703Rep9Tile metadata is consistent', () {
    final m = F0703Rep9Tile();
    expect(m.metadata.id, m.id);
  });
}
