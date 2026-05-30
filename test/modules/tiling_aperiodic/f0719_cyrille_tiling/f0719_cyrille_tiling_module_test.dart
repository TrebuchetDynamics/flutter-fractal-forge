// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0719_cyrille_tiling/f0719_cyrille_tiling_module.dart';

void main() {
  test('F0719CyrilleTiling instantiates', () {
    final m = F0719CyrilleTiling();
    expect(m.id, 'f0719_cyrille_tiling');
    expect(m.shader, 'shaders/f0719_cyrille_tiling_gpu.frag');
  });

  test('F0719CyrilleTiling presets are well-formed', () {
    final m = F0719CyrilleTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0719CyrilleTiling metadata is consistent', () {
    final m = F0719CyrilleTiling();
    expect(m.metadata.id, m.id);
  });
}
