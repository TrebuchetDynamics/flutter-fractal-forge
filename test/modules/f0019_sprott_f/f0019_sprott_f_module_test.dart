// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0019_sprott_f/f0019_sprott_f_module.dart';

void main() {
  test('F0019SprottF instantiates', () {
    final m = F0019SprottF();
    expect(m.id, 'f0019_sprott_f');
    expect(m.shader, 'shaders/f0019_sprott_f_gpu.frag');
  });

  test('F0019SprottF presets are well-formed', () {
    final m = F0019SprottF();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0019SprottF metadata is consistent', () {
    final m = F0019SprottF();
    expect(m.metadata.id, m.id);
  });
}
