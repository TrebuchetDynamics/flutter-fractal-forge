// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1099_lozi_strange/f1099_lozi_strange_module.dart';

void main() {
  test('F1099LoziStrange instantiates', () {
    final m = F1099LoziStrange();
    expect(m.id, 'f1099_lozi_strange');
    expect(m.shader, 'shaders/f1099_lozi_strange_gpu.frag');
  });

  test('F1099LoziStrange presets are well-formed', () {
    final m = F1099LoziStrange();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1099LoziStrange metadata is consistent', () {
    final m = F1099LoziStrange();
    expect(m.metadata.id, m.id);
  });
}
