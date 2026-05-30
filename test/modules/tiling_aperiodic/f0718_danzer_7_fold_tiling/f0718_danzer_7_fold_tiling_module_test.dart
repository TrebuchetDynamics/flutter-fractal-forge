// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0718_danzer_7_fold_tiling/f0718_danzer_7_fold_tiling_module.dart';

void main() {
  test('F0718Danzer7FoldTiling instantiates', () {
    final m = F0718Danzer7FoldTiling();
    expect(m.id, 'f0718_danzer_7_fold_tiling');
    expect(m.shader, 'shaders/f0718_danzer_7_fold_tiling_gpu.frag');
  });

  test('F0718Danzer7FoldTiling presets are well-formed', () {
    final m = F0718Danzer7FoldTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0718Danzer7FoldTiling metadata is consistent', () {
    final m = F0718Danzer7FoldTiling();
    expect(m.metadata.id, m.id);
  });
}
