// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0380_de_jong_leaf/f0380_de_jong_leaf_module.dart';

void main() {
  test('F0380DeJongLeaf instantiates', () {
    final m = F0380DeJongLeaf();
    expect(m.id, 'f0380_de_jong_leaf');
    expect(m.shader, 'shaders/f0380_de_jong_leaf_gpu.frag');
  });

  test('F0380DeJongLeaf presets are well-formed', () {
    final m = F0380DeJongLeaf();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0380DeJongLeaf metadata is consistent', () {
    final m = F0380DeJongLeaf();
    expect(m.metadata.id, m.id);
  });
}
