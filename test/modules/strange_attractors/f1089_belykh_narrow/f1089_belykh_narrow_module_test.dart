// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1089_belykh_narrow/f1089_belykh_narrow_module.dart';

void main() {
  test('F1089BelykhNarrow instantiates', () {
    final m = F1089BelykhNarrow();
    expect(m.id, 'f1089_belykh_narrow');
    expect(m.shader, 'shaders/f1089_belykh_narrow_gpu.frag');
  });

  test('F1089BelykhNarrow presets are well-formed', () {
    final m = F1089BelykhNarrow();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1089BelykhNarrow metadata is consistent', () {
    final m = F1089BelykhNarrow();
    expect(m.metadata.id, m.id);
  });
}
