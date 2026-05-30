// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0278_spiral_ifs/f0278_spiral_ifs_module.dart';

void main() {
  test('F0278SpiralIfs instantiates', () {
    final m = F0278SpiralIfs();
    expect(m.id, 'f0278_spiral_ifs');
    expect(m.shader, 'shaders/f0278_spiral_ifs_gpu.frag');
  });

  test('F0278SpiralIfs presets are well-formed', () {
    final m = F0278SpiralIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0278SpiralIfs metadata is consistent', () {
    final m = F0278SpiralIfs();
    expect(m.metadata.id, m.id);
  });
}
