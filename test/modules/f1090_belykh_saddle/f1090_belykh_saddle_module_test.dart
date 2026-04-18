// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1090_belykh_saddle/f1090_belykh_saddle_module.dart';

void main() {
  test('F1090BelykhSaddle instantiates', () {
    final m = F1090BelykhSaddle();
    expect(m.id, 'f1090_belykh_saddle');
    expect(m.shader, 'shaders/f1090_belykh_saddle_gpu.frag');
  });

  test('F1090BelykhSaddle presets are well-formed', () {
    final m = F1090BelykhSaddle();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1090BelykhSaddle metadata is consistent', () {
    final m = F1090BelykhSaddle();
    expect(m.metadata.id, m.id);
  });
}
