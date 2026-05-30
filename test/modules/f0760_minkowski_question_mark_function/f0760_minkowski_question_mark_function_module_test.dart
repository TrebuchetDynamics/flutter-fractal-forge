// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0760_minkowski_question_mark_function/f0760_minkowski_question_mark_function_module.dart';

void main() {
  test('F0760MinkowskiQuestionMarkFunction instantiates', () {
    final m = F0760MinkowskiQuestionMarkFunction();
    expect(m.id, 'f0760_minkowski_question_mark_function');
    expect(m.shader, 'shaders/f0760_minkowski_question_mark_function_gpu.frag');
  });

  test('F0760MinkowskiQuestionMarkFunction presets are well-formed', () {
    final m = F0760MinkowskiQuestionMarkFunction();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0760MinkowskiQuestionMarkFunction metadata is consistent', () {
    final m = F0760MinkowskiQuestionMarkFunction();
    expect(m.metadata.id, m.id);
  });
}
