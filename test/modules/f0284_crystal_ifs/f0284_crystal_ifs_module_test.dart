// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0284_crystal_ifs/f0284_crystal_ifs_module.dart';

void main() {
  test('F0284CrystalIfs instantiates', () {
    final m = F0284CrystalIfs();
    expect(m.id, 'f0284_crystal_ifs');
    expect(m.shader, 'shaders/f0284_crystal_ifs_gpu.frag');
  });

  test('F0284CrystalIfs presets are well-formed', () {
    final m = F0284CrystalIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0284CrystalIfs metadata is consistent', () {
    final m = F0284CrystalIfs();
    expect(m.metadata.id, m.id);
  });
}
