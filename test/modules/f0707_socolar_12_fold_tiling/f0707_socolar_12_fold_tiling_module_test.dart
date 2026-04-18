// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0707_socolar_12_fold_tiling/f0707_socolar_12_fold_tiling_module.dart';

void main() {
  test('F0707Socolar12FoldTiling instantiates', () {
    final m = F0707Socolar12FoldTiling();
    expect(m.id, 'f0707_socolar_12_fold_tiling');
    expect(m.shader, 'shaders/f0707_socolar_12_fold_tiling_gpu.frag');
  });

  test('F0707Socolar12FoldTiling presets are well-formed', () {
    final m = F0707Socolar12FoldTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0707Socolar12FoldTiling metadata is consistent', () {
    final m = F0707Socolar12FoldTiling();
    expect(m.metadata.id, m.id);
  });
}
