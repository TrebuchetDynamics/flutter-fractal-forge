// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0338_clifford_tornado/f0338_clifford_tornado_module.dart';

void main() {
  test('F0338CliffordTornado instantiates', () {
    final m = F0338CliffordTornado();
    expect(m.id, 'f0338_clifford_tornado');
    expect(m.shader, 'shaders/f0338_clifford_tornado_gpu.frag');
  });

  test('F0338CliffordTornado presets are well-formed', () {
    final m = F0338CliffordTornado();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0338CliffordTornado metadata is consistent', () {
    final m = F0338CliffordTornado();
    expect(m.metadata.id, m.id);
  });
}
