// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0352_clifford_coral/f0352_clifford_coral_module.dart';

void main() {
  test('F0352CliffordCoral instantiates', () {
    final m = F0352CliffordCoral();
    expect(m.id, 'f0352_clifford_coral');
    expect(m.shader, 'shaders/f0352_clifford_coral_gpu.frag');
  });

  test('F0352CliffordCoral presets are well-formed', () {
    final m = F0352CliffordCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0352CliffordCoral metadata is consistent', () {
    final m = F0352CliffordCoral();
    expect(m.metadata.id, m.id);
  });
}
