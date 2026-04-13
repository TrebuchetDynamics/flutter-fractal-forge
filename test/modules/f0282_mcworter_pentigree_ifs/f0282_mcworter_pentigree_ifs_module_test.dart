// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0282_mcworter_pentigree_ifs/f0282_mcworter_pentigree_ifs_module.dart';

void main() {
  test('F0282McworterPentigreeIfs instantiates', () {
    final m = F0282McworterPentigreeIfs();
    expect(m.id, 'f0282_mcworter_pentigree_ifs');
    expect(m.shader, 'shaders/f0282_mcworter_pentigree_ifs_gpu.frag');
  });

  test('F0282McworterPentigreeIfs presets are well-formed', () {
    final m = F0282McworterPentigreeIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0282McworterPentigreeIfs metadata is consistent', () {
    final m = F0282McworterPentigreeIfs();
    expect(m.metadata.id, m.id);
  });
}
