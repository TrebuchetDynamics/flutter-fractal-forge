// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1098_lozi_compact/f1098_lozi_compact_module.dart';

void main() {
  test('F1098LoziCompact instantiates', () {
    final m = F1098LoziCompact();
    expect(m.id, 'f1098_lozi_compact');
    expect(m.shader, 'shaders/f1098_lozi_compact_gpu.frag');
  });

  test('F1098LoziCompact presets are well-formed', () {
    final m = F1098LoziCompact();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1098LoziCompact metadata is consistent', () {
    final m = F1098LoziCompact();
    expect(m.metadata.id, m.id);
  });
}
