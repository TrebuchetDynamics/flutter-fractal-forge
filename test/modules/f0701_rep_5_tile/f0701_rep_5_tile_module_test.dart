// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0701_rep_5_tile/f0701_rep_5_tile_module.dart';

void main() {
  test('F0701Rep5Tile instantiates', () {
    final m = F0701Rep5Tile();
    expect(m.id, 'f0701_rep_5_tile');
    expect(m.shader, 'shaders/f0701_rep_5_tile_gpu.frag');
  });

  test('F0701Rep5Tile presets are well-formed', () {
    final m = F0701Rep5Tile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0701Rep5Tile metadata is consistent', () {
    final m = F0701Rep5Tile();
    expect(m.metadata.id, m.id);
  });
}
