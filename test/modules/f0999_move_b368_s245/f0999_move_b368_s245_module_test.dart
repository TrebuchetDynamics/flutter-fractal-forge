// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0999_move_b368_s245/f0999_move_b368_s245_module.dart';

void main() {
  test('F0999MoveB368S245 instantiates', () {
    final m = F0999MoveB368S245();
    expect(m.id, 'f0999_move_b368_s245');
    expect(m.shader, 'shaders/f0999_move_b368_s245_gpu.frag');
  });

  test('F0999MoveB368S245 presets are well-formed', () {
    final m = F0999MoveB368S245();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0999MoveB368S245 metadata is consistent', () {
    final m = F0999MoveB368S245();
    expect(m.metadata.id, m.id);
  });
}
