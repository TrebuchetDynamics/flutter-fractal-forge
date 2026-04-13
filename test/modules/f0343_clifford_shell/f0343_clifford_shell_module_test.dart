// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0343_clifford_shell/f0343_clifford_shell_module.dart';

void main() {
  test('F0343CliffordShell instantiates', () {
    final m = F0343CliffordShell();
    expect(m.id, 'f0343_clifford_shell');
    expect(m.shader, 'shaders/f0343_clifford_shell_gpu.frag');
  });

  test('F0343CliffordShell presets are well-formed', () {
    final m = F0343CliffordShell();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0343CliffordShell metadata is consistent', () {
    final m = F0343CliffordShell();
    expect(m.metadata.id, m.id);
  });
}
