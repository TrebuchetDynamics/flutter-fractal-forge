// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0208_clifford_attractor/f0208_clifford_attractor_module.dart';

void main() {
  test('F0208CliffordAttractor instantiates', () {
    final m = F0208CliffordAttractor();
    expect(m.id, 'f0208_clifford_attractor');
    expect(m.shader, 'shaders/f0208_clifford_attractor_gpu.frag');
  });

  test('F0208CliffordAttractor presets are well-formed', () {
    final m = F0208CliffordAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0208CliffordAttractor metadata is consistent', () {
    final m = F0208CliffordAttractor();
    expect(m.metadata.id, m.id);
  });
}
