// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0081_hindmarsh_rose/f0081_hindmarsh_rose_module.dart';

void main() {
  test('F0081HindmarshRose instantiates', () {
    final m = F0081HindmarshRose();
    expect(m.id, 'f0081_hindmarsh_rose');
    expect(m.shader, 'shaders/f0081_hindmarsh_rose_gpu.frag');
  });

  test('F0081HindmarshRose presets are well-formed', () {
    final m = F0081HindmarshRose();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0081HindmarshRose metadata is consistent', () {
    final m = F0081HindmarshRose();
    expect(m.metadata.id, m.id);
  });
}
