// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1062_tyler_flower/f1062_tyler_flower_module.dart';

void main() {
  test('F1062TylerFlower instantiates', () {
    final m = F1062TylerFlower();
    expect(m.id, 'f1062_tyler_flower');
    expect(m.shader, 'shaders/f1062_tyler_flower_gpu.frag');
  });

  test('F1062TylerFlower presets are well-formed', () {
    final m = F1062TylerFlower();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1062TylerFlower metadata is consistent', () {
    final m = F1062TylerFlower();
    expect(m.metadata.id, m.id);
  });
}
