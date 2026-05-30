// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1100_lozi_wide/f1100_lozi_wide_module.dart';

void main() {
  test('F1100LoziWide instantiates', () {
    final m = F1100LoziWide();
    expect(m.id, 'f1100_lozi_wide');
    expect(m.shader, 'shaders/f1100_lozi_wide_gpu.frag');
  });

  test('F1100LoziWide presets are well-formed', () {
    final m = F1100LoziWide();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1100LoziWide metadata is consistent', () {
    final m = F1100LoziWide();
    expect(m.metadata.id, m.id);
  });
}
