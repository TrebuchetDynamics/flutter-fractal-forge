// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1017_byl_s_self_reproducer/f1017_byl_s_self_reproducer_module.dart';

void main() {
  test('F1017BylSSelfReproducer instantiates', () {
    final m = F1017BylSSelfReproducer();
    expect(m.id, 'f1017_byl_s_self_reproducer');
    expect(m.shader, 'shaders/f1017_byl_s_self_reproducer_gpu.frag');
  });

  test('F1017BylSSelfReproducer presets are well-formed', () {
    final m = F1017BylSSelfReproducer();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1017BylSSelfReproducer metadata is consistent', () {
    final m = F1017BylSSelfReproducer();
    expect(m.metadata.id, m.id);
  });
}
