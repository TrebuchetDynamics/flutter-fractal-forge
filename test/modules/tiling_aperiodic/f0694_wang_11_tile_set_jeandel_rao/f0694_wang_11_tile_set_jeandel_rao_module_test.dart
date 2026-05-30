// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0694_wang_11_tile_set_jeandel_rao/f0694_wang_11_tile_set_jeandel_rao_module.dart';

void main() {
  test('F0694Wang11TileSetJeandelRao instantiates', () {
    final m = F0694Wang11TileSetJeandelRao();
    expect(m.id, 'f0694_wang_11_tile_set_jeandel_rao');
    expect(m.shader, 'shaders/f0694_wang_11_tile_set_jeandel_rao_gpu.frag');
  });

  test('F0694Wang11TileSetJeandelRao presets are well-formed', () {
    final m = F0694Wang11TileSetJeandelRao();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0694Wang11TileSetJeandelRao metadata is consistent', () {
    final m = F0694Wang11TileSetJeandelRao();
    expect(m.metadata.id, m.id);
  });
}
