// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1087_belykh_classic/f1087_belykh_classic_module.dart';

void main() {
  test('F1087BelykhClassic instantiates', () {
    final m = F1087BelykhClassic();
    expect(m.id, 'f1087_belykh_classic');
    expect(m.shader, 'shaders/f1087_belykh_classic_gpu.frag');
  });

  test('F1087BelykhClassic presets are well-formed', () {
    final m = F1087BelykhClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1087BelykhClassic metadata is consistent', () {
    final m = F1087BelykhClassic();
    expect(m.metadata.id, m.id);
  });
}
