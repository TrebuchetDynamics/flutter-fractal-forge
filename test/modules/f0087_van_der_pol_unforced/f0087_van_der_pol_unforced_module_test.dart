// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0087_van_der_pol_unforced/f0087_van_der_pol_unforced_module.dart';

void main() {
  test('F0087VanDerPolUnforced instantiates', () {
    final m = F0087VanDerPolUnforced();
    expect(m.id, 'f0087_van_der_pol_unforced');
    expect(m.shader, 'shaders/f0087_van_der_pol_unforced_gpu.frag');
  });

  test('F0087VanDerPolUnforced presets are well-formed', () {
    final m = F0087VanDerPolUnforced();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0087VanDerPolUnforced metadata is consistent', () {
    final m = F0087VanDerPolUnforced();
    expect(m.metadata.id, m.id);
  });
}
