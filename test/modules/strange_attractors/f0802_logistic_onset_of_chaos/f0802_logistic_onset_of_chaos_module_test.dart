// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0802_logistic_onset_of_chaos/f0802_logistic_onset_of_chaos_module.dart';

void main() {
  test('F0802LogisticOnsetOfChaos instantiates', () {
    final m = F0802LogisticOnsetOfChaos();
    expect(m.id, 'f0802_logistic_onset_of_chaos');
    expect(m.shader, 'shaders/f0802_logistic_onset_of_chaos_gpu.frag');
  });

  test('F0802LogisticOnsetOfChaos presets are well-formed', () {
    final m = F0802LogisticOnsetOfChaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0802LogisticOnsetOfChaos metadata is consistent', () {
    final m = F0802LogisticOnsetOfChaos();
    expect(m.metadata.id, m.id);
  });
}
