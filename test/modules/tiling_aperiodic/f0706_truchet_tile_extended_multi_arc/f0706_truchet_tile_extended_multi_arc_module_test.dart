// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0706_truchet_tile_extended_multi_arc/f0706_truchet_tile_extended_multi_arc_module.dart';

void main() {
  test('F0706TruchetTileExtendedMultiArc instantiates', () {
    final m = F0706TruchetTileExtendedMultiArc();
    expect(m.id, 'f0706_truchet_tile_extended_multi_arc');
    expect(m.shader, 'shaders/f0706_truchet_tile_extended_multi_arc_gpu.frag');
  });

  test('F0706TruchetTileExtendedMultiArc presets are well-formed', () {
    final m = F0706TruchetTileExtendedMultiArc();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0706TruchetTileExtendedMultiArc metadata is consistent', () {
    final m = F0706TruchetTileExtendedMultiArc();
    expect(m.metadata.id, m.id);
  });
}
