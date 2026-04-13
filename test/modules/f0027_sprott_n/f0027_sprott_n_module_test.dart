// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0027_sprott_n/f0027_sprott_n_module.dart';

void main() {
  test('F0027SprottN instantiates', () {
    final m = F0027SprottN();
    expect(m.id, 'f0027_sprott_n');
    expect(m.shader, 'shaders/f0027_sprott_n_gpu.frag');
  });

  test('F0027SprottN presets are well-formed', () {
    final m = F0027SprottN();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0027SprottN metadata is consistent', () {
    final m = F0027SprottN();
    expect(m.metadata.id, m.id);
  });
}
