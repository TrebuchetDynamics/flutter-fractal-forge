// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0017_sprott_d/f0017_sprott_d_module.dart';

void main() {
  test('F0017SprottD instantiates', () {
    final m = F0017SprottD();
    expect(m.id, 'f0017_sprott_d');
    expect(m.shader, 'shaders/f0017_sprott_d_gpu.frag');
  });

  test('F0017SprottD presets are well-formed', () {
    final m = F0017SprottD();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0017SprottD metadata is consistent', () {
    final m = F0017SprottD();
    expect(m.metadata.id, m.id);
  });
}
