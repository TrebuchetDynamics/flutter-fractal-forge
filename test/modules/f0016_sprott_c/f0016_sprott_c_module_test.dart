// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0016_sprott_c/f0016_sprott_c_module.dart';

void main() {
  test('F0016SprottC instantiates', () {
    final m = F0016SprottC();
    expect(m.id, 'f0016_sprott_c');
    expect(m.shader, 'shaders/f0016_sprott_c_gpu.frag');
  });

  test('F0016SprottC presets are well-formed', () {
    final m = F0016SprottC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0016SprottC metadata is consistent', () {
    final m = F0016SprottC();
    expect(m.metadata.id, m.id);
  });
}
