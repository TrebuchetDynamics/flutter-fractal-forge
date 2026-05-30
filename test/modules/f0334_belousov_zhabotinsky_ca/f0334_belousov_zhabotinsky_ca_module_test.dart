// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0334_belousov_zhabotinsky_ca/f0334_belousov_zhabotinsky_ca_module.dart';

void main() {
  test('F0334BelousovZhabotinskyCa instantiates', () {
    final m = F0334BelousovZhabotinskyCa();
    expect(m.id, 'f0334_belousov_zhabotinsky_ca');
    expect(m.shader, 'shaders/f0334_belousov_zhabotinsky_ca_gpu.frag');
  });

  test('F0334BelousovZhabotinskyCa presets are well-formed', () {
    final m = F0334BelousovZhabotinskyCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0334BelousovZhabotinskyCa metadata is consistent', () {
    final m = F0334BelousovZhabotinskyCa();
    expect(m.metadata.id, m.id);
  });
}
