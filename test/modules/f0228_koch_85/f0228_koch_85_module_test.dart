// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0228_koch_85/f0228_koch_85_module.dart';

void main() {
  test('F0228Koch85 instantiates', () {
    final m = F0228Koch85();
    expect(m.id, 'f0228_koch_85');
    expect(m.shader, 'shaders/f0228_koch_85_gpu.frag');
  });

  test('F0228Koch85 presets are well-formed', () {
    final m = F0228Koch85();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0228Koch85 metadata is consistent', () {
    final m = F0228Koch85();
    expect(m.metadata.id, m.id);
  });
}
