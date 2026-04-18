// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0996_walled_cities_b45678_s2345/f0996_walled_cities_b45678_s2345_module.dart';

void main() {
  test('F0996WalledCitiesB45678S2345 instantiates', () {
    final m = F0996WalledCitiesB45678S2345();
    expect(m.id, 'f0996_walled_cities_b45678_s2345');
    expect(m.shader, 'shaders/f0996_walled_cities_b45678_s2345_gpu.frag');
  });

  test('F0996WalledCitiesB45678S2345 presets are well-formed', () {
    final m = F0996WalledCitiesB45678S2345();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0996WalledCitiesB45678S2345 metadata is consistent', () {
    final m = F0996WalledCitiesB45678S2345();
    expect(m.metadata.id, m.id);
  });
}
