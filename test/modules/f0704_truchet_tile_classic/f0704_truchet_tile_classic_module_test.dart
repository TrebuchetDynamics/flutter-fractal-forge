// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0704_truchet_tile_classic/f0704_truchet_tile_classic_module.dart';

void main() {
  test('F0704TruchetTileClassic instantiates', () {
    final m = F0704TruchetTileClassic();
    expect(m.id, 'f0704_truchet_tile_classic');
    expect(m.shader, 'shaders/f0704_truchet_tile_classic_gpu.frag');
  });

  test('F0704TruchetTileClassic presets are well-formed', () {
    final m = F0704TruchetTileClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0704TruchetTileClassic metadata is consistent', () {
    final m = F0704TruchetTileClassic();
    expect(m.metadata.id, m.id);
  });
}
