// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1088_belykh_wide/f1088_belykh_wide_module.dart';

void main() {
  test('F1088BelykhWide instantiates', () {
    final m = F1088BelykhWide();
    expect(m.id, 'f1088_belykh_wide');
    expect(m.shader, 'shaders/f1088_belykh_wide_gpu.frag');
  });

  test('F1088BelykhWide presets are well-formed', () {
    final m = F1088BelykhWide();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1088BelykhWide metadata is consistent', () {
    final m = F1088BelykhWide();
    expect(m.metadata.id, m.id);
  });
}
