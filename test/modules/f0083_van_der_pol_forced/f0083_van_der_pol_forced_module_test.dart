// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0083_van_der_pol_forced/f0083_van_der_pol_forced_module.dart';

void main() {
  test('F0083VanDerPolForced instantiates', () {
    final m = F0083VanDerPolForced();
    expect(m.id, 'f0083_van_der_pol_forced');
    expect(m.shader, 'shaders/f0083_van_der_pol_forced_gpu.frag');
  });

  test('F0083VanDerPolForced presets are well-formed', () {
    final m = F0083VanDerPolForced();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0083VanDerPolForced metadata is consistent', () {
    final m = F0083VanDerPolForced();
    expect(m.metadata.id, m.id);
  });
}
