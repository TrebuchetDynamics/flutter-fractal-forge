// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0061_dadras_attractor/f0061_dadras_attractor_module.dart';

void main() {
  test('F0061DadrasAttractor instantiates', () {
    final m = F0061DadrasAttractor();
    expect(m.id, 'f0061_dadras_attractor');
    expect(m.shader, 'shaders/f0061_dadras_attractor_gpu.frag');
  });

  test('F0061DadrasAttractor presets are well-formed', () {
    final m = F0061DadrasAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0061DadrasAttractor metadata is consistent', () {
    final m = F0061DadrasAttractor();
    expect(m.metadata.id, m.id);
  });
}
