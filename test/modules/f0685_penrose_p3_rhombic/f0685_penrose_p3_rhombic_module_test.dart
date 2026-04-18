// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0685_penrose_p3_rhombic/f0685_penrose_p3_rhombic_module.dart';

void main() {
  test('F0685PenroseP3Rhombic instantiates', () {
    final m = F0685PenroseP3Rhombic();
    expect(m.id, 'f0685_penrose_p3_rhombic');
    expect(m.shader, 'shaders/f0685_penrose_p3_rhombic_gpu.frag');
  });

  test('F0685PenroseP3Rhombic presets are well-formed', () {
    final m = F0685PenroseP3Rhombic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0685PenroseP3Rhombic metadata is consistent', () {
    final m = F0685PenroseP3Rhombic();
    expect(m.metadata.id, m.id);
  });
}
