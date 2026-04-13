// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0283_maple_leaf_ifs/f0283_maple_leaf_ifs_module.dart';

void main() {
  test('F0283MapleLeafIfs instantiates', () {
    final m = F0283MapleLeafIfs();
    expect(m.id, 'f0283_maple_leaf_ifs');
    expect(m.shader, 'shaders/f0283_maple_leaf_ifs_gpu.frag');
  });

  test('F0283MapleLeafIfs presets are well-formed', () {
    final m = F0283MapleLeafIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0283MapleLeafIfs metadata is consistent', () {
    final m = F0283MapleLeafIfs();
    expect(m.metadata.id, m.id);
  });
}
