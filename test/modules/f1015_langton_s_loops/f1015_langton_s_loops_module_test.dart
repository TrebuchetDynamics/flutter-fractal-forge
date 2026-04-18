// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1015_langton_s_loops/f1015_langton_s_loops_module.dart';

void main() {
  test('F1015LangtonSLoops instantiates', () {
    final m = F1015LangtonSLoops();
    expect(m.id, 'f1015_langton_s_loops');
    expect(m.shader, 'shaders/f1015_langton_s_loops_gpu.frag');
  });

  test('F1015LangtonSLoops presets are well-formed', () {
    final m = F1015LangtonSLoops();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1015LangtonSLoops metadata is consistent', () {
    final m = F1015LangtonSLoops();
    expect(m.metadata.id, m.id);
  });
}
