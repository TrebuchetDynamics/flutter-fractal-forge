// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0322_highlife/f0322_highlife_module.dart';

void main() {
  test('F0322Highlife instantiates', () {
    final m = F0322Highlife();
    expect(m.id, 'f0322_highlife');
    expect(m.shader, 'shaders/f0322_highlife_gpu.frag');
  });

  test('F0322Highlife presets are well-formed', () {
    final m = F0322Highlife();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0322Highlife metadata is consistent', () {
    final m = F0322Highlife();
    expect(m.metadata.id, m.id);
  });
}
