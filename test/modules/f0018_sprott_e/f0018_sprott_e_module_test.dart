// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0018_sprott_e/f0018_sprott_e_module.dart';

void main() {
  test('F0018SprottE instantiates', () {
    final m = F0018SprottE();
    expect(m.id, 'f0018_sprott_e');
    expect(m.shader, 'shaders/f0018_sprott_e_gpu.frag');
  });

  test('F0018SprottE presets are well-formed', () {
    final m = F0018SprottE();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0018SprottE metadata is consistent', () {
    final m = F0018SprottE();
    expect(m.metadata.id, m.id);
  });
}
