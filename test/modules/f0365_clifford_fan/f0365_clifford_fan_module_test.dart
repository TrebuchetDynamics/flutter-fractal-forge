// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0365_clifford_fan/f0365_clifford_fan_module.dart';

void main() {
  test('F0365CliffordFan instantiates', () {
    final m = F0365CliffordFan();
    expect(m.id, 'f0365_clifford_fan');
    expect(m.shader, 'shaders/f0365_clifford_fan_gpu.frag');
  });

  test('F0365CliffordFan presets are well-formed', () {
    final m = F0365CliffordFan();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0365CliffordFan metadata is consistent', () {
    final m = F0365CliffordFan();
    expect(m.metadata.id, m.id);
  });
}
