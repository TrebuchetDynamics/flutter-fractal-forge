// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0280_leaf_ifs/f0280_leaf_ifs_module.dart';

void main() {
  test('F0280LeafIfs instantiates', () {
    final m = F0280LeafIfs();
    expect(m.id, 'f0280_leaf_ifs');
    expect(m.shader, 'shaders/f0280_leaf_ifs_gpu.frag');
  });

  test('F0280LeafIfs presets are well-formed', () {
    final m = F0280LeafIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0280LeafIfs metadata is consistent', () {
    final m = F0280LeafIfs();
    expect(m.metadata.id, m.id);
  });
}
