// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0700_rep_4_l_tile/f0700_rep_4_l_tile_module.dart';

void main() {
  test('F0700Rep4LTile instantiates', () {
    final m = F0700Rep4LTile();
    expect(m.id, 'f0700_rep_4_l_tile');
    expect(m.shader, 'shaders/f0700_rep_4_l_tile_gpu.frag');
  });

  test('F0700Rep4LTile presets are well-formed', () {
    final m = F0700Rep4LTile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0700Rep4LTile metadata is consistent', () {
    final m = F0700Rep4LTile();
    expect(m.metadata.id, m.id);
  });
}
