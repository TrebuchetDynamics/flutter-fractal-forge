// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0320_seeds_ca/f0320_seeds_ca_module.dart';

void main() {
  test('F0320SeedsCa instantiates', () {
    final m = F0320SeedsCa();
    expect(m.id, 'f0320_seeds_ca');
    expect(m.shader, 'shaders/f0320_seeds_ca_gpu.frag');
  });

  test('F0320SeedsCa presets are well-formed', () {
    final m = F0320SeedsCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0320SeedsCa metadata is consistent', () {
    final m = F0320SeedsCa();
    expect(m.metadata.id, m.id);
  });
}
