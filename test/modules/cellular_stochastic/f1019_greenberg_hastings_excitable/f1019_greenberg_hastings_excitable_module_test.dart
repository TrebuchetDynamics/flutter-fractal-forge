// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1019_greenberg_hastings_excitable/f1019_greenberg_hastings_excitable_module.dart';

void main() {
  test('F1019GreenbergHastingsExcitable instantiates', () {
    final m = F1019GreenbergHastingsExcitable();
    expect(m.id, 'f1019_greenberg_hastings_excitable');
    expect(m.shader, 'shaders/f1019_greenberg_hastings_excitable_gpu.frag');
  });

  test('F1019GreenbergHastingsExcitable presets are well-formed', () {
    final m = F1019GreenbergHastingsExcitable();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1019GreenbergHastingsExcitable metadata is consistent', () {
    final m = F1019GreenbergHastingsExcitable();
    expect(m.metadata.id, m.id);
  });
}
