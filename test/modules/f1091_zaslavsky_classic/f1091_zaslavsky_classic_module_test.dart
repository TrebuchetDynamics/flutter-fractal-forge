// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1091_zaslavsky_classic/f1091_zaslavsky_classic_module.dart';

void main() {
  test('F1091ZaslavskyClassic instantiates', () {
    final m = F1091ZaslavskyClassic();
    expect(m.id, 'f1091_zaslavsky_classic');
    expect(m.shader, 'shaders/f1091_zaslavsky_classic_gpu.frag');
  });

  test('F1091ZaslavskyClassic presets are well-formed', () {
    final m = F1091ZaslavskyClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1091ZaslavskyClassic metadata is consistent', () {
    final m = F1091ZaslavskyClassic();
    expect(m.metadata.id, m.id);
  });
}
