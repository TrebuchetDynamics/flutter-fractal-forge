// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0693_wang_tile_set_kari_culik_13_tile/f0693_wang_tile_set_kari_culik_13_tile_module.dart';

void main() {
  test('F0693WangTileSetKariCulik13Tile instantiates', () {
    final m = F0693WangTileSetKariCulik13Tile();
    expect(m.id, 'f0693_wang_tile_set_kari_culik_13_tile');
    expect(m.shader, 'shaders/f0693_wang_tile_set_kari_culik_13_tile_gpu.frag');
  });

  test('F0693WangTileSetKariCulik13Tile presets are well-formed', () {
    final m = F0693WangTileSetKariCulik13Tile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0693WangTileSetKariCulik13Tile metadata is consistent', () {
    final m = F0693WangTileSetKariCulik13Tile();
    expect(m.metadata.id, m.id);
  });
}
