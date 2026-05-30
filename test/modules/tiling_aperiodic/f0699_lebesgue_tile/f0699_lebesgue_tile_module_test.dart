// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0699_lebesgue_tile/f0699_lebesgue_tile_module.dart';

void main() {
  test('F0699LebesgueTile instantiates', () {
    final m = F0699LebesgueTile();
    expect(m.id, 'f0699_lebesgue_tile');
    expect(m.shader, 'shaders/f0699_lebesgue_tile_gpu.frag');
  });

  test('F0699LebesgueTile presets are well-formed', () {
    final m = F0699LebesgueTile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0699LebesgueTile metadata is consistent', () {
    final m = F0699LebesgueTile();
    expect(m.metadata.id, m.id);
  });
}
