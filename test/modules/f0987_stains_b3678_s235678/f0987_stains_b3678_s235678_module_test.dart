// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0987_stains_b3678_s235678/f0987_stains_b3678_s235678_module.dart';

void main() {
  test('F0987StainsB3678S235678 instantiates', () {
    final m = F0987StainsB3678S235678();
    expect(m.id, 'f0987_stains_b3678_s235678');
    expect(m.shader, 'shaders/f0987_stains_b3678_s235678_gpu.frag');
  });

  test('F0987StainsB3678S235678 presets are well-formed', () {
    final m = F0987StainsB3678S235678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0987StainsB3678S235678 metadata is consistent', () {
    final m = F0987StainsB3678S235678();
    expect(m.metadata.id, m.id);
  });
}
