// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0324_move/f0324_move_module.dart';

void main() {
  test('F0324Move instantiates', () {
    final m = F0324Move();
    expect(m.id, 'f0324_move');
    expect(m.shader, 'shaders/f0324_move_gpu.frag');
  });

  test('F0324Move presets are well-formed', () {
    final m = F0324Move();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0324Move metadata is consistent', () {
    final m = F0324Move();
    expect(m.metadata.id, m.id);
  });
}
