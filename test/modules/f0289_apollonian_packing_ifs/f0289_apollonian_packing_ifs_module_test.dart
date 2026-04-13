// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0289_apollonian_packing_ifs/f0289_apollonian_packing_ifs_module.dart';

void main() {
  test('F0289ApollonianPackingIfs instantiates', () {
    final m = F0289ApollonianPackingIfs();
    expect(m.id, 'f0289_apollonian_packing_ifs');
    expect(m.shader, 'shaders/f0289_apollonian_packing_ifs_gpu.frag');
  });

  test('F0289ApollonianPackingIfs presets are well-formed', () {
    final m = F0289ApollonianPackingIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0289ApollonianPackingIfs metadata is consistent', () {
    final m = F0289ApollonianPackingIfs();
    expect(m.metadata.id, m.id);
  });
}
