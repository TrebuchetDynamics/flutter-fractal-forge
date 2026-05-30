// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0354_clifford_flower/f0354_clifford_flower_module.dart';

void main() {
  test('F0354CliffordFlower instantiates', () {
    final m = F0354CliffordFlower();
    expect(m.id, 'f0354_clifford_flower');
    expect(m.shader, 'shaders/f0354_clifford_flower_gpu.frag');
  });

  test('F0354CliffordFlower presets are well-formed', () {
    final m = F0354CliffordFlower();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0354CliffordFlower metadata is consistent', () {
    final m = F0354CliffordFlower();
    expect(m.metadata.id, m.id);
  });
}
