// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0335_sand_pile_model_btw/f0335_sand_pile_model_btw_module.dart';

void main() {
  test('F0335SandPileModelBtw instantiates', () {
    final m = F0335SandPileModelBtw();
    expect(m.id, 'f0335_sand_pile_model_btw');
    expect(m.shader, 'shaders/f0335_sand_pile_model_btw_gpu.frag');
  });

  test('F0335SandPileModelBtw presets are well-formed', () {
    final m = F0335SandPileModelBtw();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0335SandPileModelBtw metadata is consistent', () {
    final m = F0335SandPileModelBtw();
    expect(m.metadata.id, m.id);
  });
}
