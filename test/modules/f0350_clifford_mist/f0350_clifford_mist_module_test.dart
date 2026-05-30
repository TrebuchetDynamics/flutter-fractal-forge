// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0350_clifford_mist/f0350_clifford_mist_module.dart';

void main() {
  test('F0350CliffordMist instantiates', () {
    final m = F0350CliffordMist();
    expect(m.id, 'f0350_clifford_mist');
    expect(m.shader, 'shaders/f0350_clifford_mist_gpu.frag');
  });

  test('F0350CliffordMist presets are well-formed', () {
    final m = F0350CliffordMist();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0350CliffordMist metadata is consistent', () {
    final m = F0350CliffordMist();
    expect(m.metadata.id, m.id);
  });
}
