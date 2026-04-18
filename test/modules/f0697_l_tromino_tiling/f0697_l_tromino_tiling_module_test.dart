// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0697_l_tromino_tiling/f0697_l_tromino_tiling_module.dart';

void main() {
  test('F0697LTrominoTiling instantiates', () {
    final m = F0697LTrominoTiling();
    expect(m.id, 'f0697_l_tromino_tiling');
    expect(m.shader, 'shaders/f0697_l_tromino_tiling_gpu.frag');
  });

  test('F0697LTrominoTiling presets are well-formed', () {
    final m = F0697LTrominoTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0697LTrominoTiling metadata is consistent', () {
    final m = F0697LTrominoTiling();
    expect(m.metadata.id, m.id);
  });
}
