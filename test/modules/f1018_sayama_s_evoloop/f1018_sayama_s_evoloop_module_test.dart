// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1018_sayama_s_evoloop/f1018_sayama_s_evoloop_module.dart';

void main() {
  test('F1018SayamaSEvoloop instantiates', () {
    final m = F1018SayamaSEvoloop();
    expect(m.id, 'f1018_sayama_s_evoloop');
    expect(m.shader, 'shaders/f1018_sayama_s_evoloop_gpu.frag');
  });

  test('F1018SayamaSEvoloop presets are well-formed', () {
    final m = F1018SayamaSEvoloop();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1018SayamaSEvoloop metadata is consistent', () {
    final m = F1018SayamaSEvoloop();
    expect(m.metadata.id, m.id);
  });
}
