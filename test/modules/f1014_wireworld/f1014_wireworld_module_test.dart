// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1014_wireworld/f1014_wireworld_module.dart';

void main() {
  test('F1014Wireworld instantiates', () {
    final m = F1014Wireworld();
    expect(m.id, 'f1014_wireworld');
    expect(m.shader, 'shaders/f1014_wireworld_gpu.frag');
  });

  test('F1014Wireworld presets are well-formed', () {
    final m = F1014Wireworld();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1014Wireworld metadata is consistent', () {
    final m = F1014Wireworld();
    expect(m.metadata.id, m.id);
  });
}
