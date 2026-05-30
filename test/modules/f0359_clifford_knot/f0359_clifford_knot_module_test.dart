// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0359_clifford_knot/f0359_clifford_knot_module.dart';

void main() {
  test('F0359CliffordKnot instantiates', () {
    final m = F0359CliffordKnot();
    expect(m.id, 'f0359_clifford_knot');
    expect(m.shader, 'shaders/f0359_clifford_knot_gpu.frag');
  });

  test('F0359CliffordKnot presets are well-formed', () {
    final m = F0359CliffordKnot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0359CliffordKnot metadata is consistent', () {
    final m = F0359CliffordKnot();
    expect(m.metadata.id, m.id);
  });
}
