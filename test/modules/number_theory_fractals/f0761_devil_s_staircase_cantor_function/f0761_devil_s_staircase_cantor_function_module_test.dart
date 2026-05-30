// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0761_devil_s_staircase_cantor_function/f0761_devil_s_staircase_cantor_function_module.dart';

void main() {
  test('F0761DevilSStaircaseCantorFunction instantiates', () {
    final m = F0761DevilSStaircaseCantorFunction();
    expect(m.id, 'f0761_devil_s_staircase_cantor_function');
    expect(
        m.shader, 'shaders/f0761_devil_s_staircase_cantor_function_gpu.frag');
  });

  test('F0761DevilSStaircaseCantorFunction presets are well-formed', () {
    final m = F0761DevilSStaircaseCantorFunction();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0761DevilSStaircaseCantorFunction metadata is consistent', () {
    final m = F0761DevilSStaircaseCantorFunction();
    expect(m.metadata.id, m.id);
  });
}
