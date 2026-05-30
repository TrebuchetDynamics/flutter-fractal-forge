// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0362_clifford_tendrils/f0362_clifford_tendrils_module.dart';

void main() {
  test('F0362CliffordTendrils instantiates', () {
    final m = F0362CliffordTendrils();
    expect(m.id, 'f0362_clifford_tendrils');
    expect(m.shader, 'shaders/f0362_clifford_tendrils_gpu.frag');
  });

  test('F0362CliffordTendrils presets are well-formed', () {
    final m = F0362CliffordTendrils();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0362CliffordTendrils metadata is consistent', () {
    final m = F0362CliffordTendrils();
    expect(m.metadata.id, m.id);
  });
}
