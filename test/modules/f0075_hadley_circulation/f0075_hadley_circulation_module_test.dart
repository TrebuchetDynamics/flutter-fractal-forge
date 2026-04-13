// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0075_hadley_circulation/f0075_hadley_circulation_module.dart';

void main() {
  test('F0075HadleyCirculation instantiates', () {
    final m = F0075HadleyCirculation();
    expect(m.id, 'f0075_hadley_circulation');
    expect(m.shader, 'shaders/f0075_hadley_circulation_gpu.frag');
  });

  test('F0075HadleyCirculation presets are well-formed', () {
    final m = F0075HadleyCirculation();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0075HadleyCirculation metadata is consistent', () {
    final m = F0075HadleyCirculation();
    expect(m.metadata.id, m.id);
  });
}
