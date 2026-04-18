// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0705_truchet_tile_smith_quarter_arcs/f0705_truchet_tile_smith_quarter_arcs_module.dart';

void main() {
  test('F0705TruchetTileSmithQuarterArcs instantiates', () {
    final m = F0705TruchetTileSmithQuarterArcs();
    expect(m.id, 'f0705_truchet_tile_smith_quarter_arcs');
    expect(m.shader, 'shaders/f0705_truchet_tile_smith_quarter_arcs_gpu.frag');
  });

  test('F0705TruchetTileSmithQuarterArcs presets are well-formed', () {
    final m = F0705TruchetTileSmithQuarterArcs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0705TruchetTileSmithQuarterArcs metadata is consistent', () {
    final m = F0705TruchetTileSmithQuarterArcs();
    expect(m.metadata.id, m.id);
  });
}
