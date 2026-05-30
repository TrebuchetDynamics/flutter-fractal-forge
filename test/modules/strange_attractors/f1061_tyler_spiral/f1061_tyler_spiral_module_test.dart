// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1061_tyler_spiral/f1061_tyler_spiral_module.dart';

void main() {
  test('F1061TylerSpiral instantiates', () {
    final m = F1061TylerSpiral();
    expect(m.id, 'f1061_tyler_spiral');
    expect(m.shader, 'shaders/f1061_tyler_spiral_gpu.frag');
  });

  test('F1061TylerSpiral presets are well-formed', () {
    final m = F1061TylerSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1061TylerSpiral metadata is consistent', () {
    final m = F1061TylerSpiral();
    expect(m.metadata.id, m.id);
  });
}
