// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0033_sprott_linz_a/f0033_sprott_linz_a_module.dart';

void main() {
  test('F0033SprottLinzA instantiates', () {
    final m = F0033SprottLinzA();
    expect(m.id, 'f0033_sprott_linz_a');
    expect(m.shader, 'shaders/f0033_sprott_linz_a_gpu.frag');
  });

  test('F0033SprottLinzA presets are well-formed', () {
    final m = F0033SprottLinzA();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0033SprottLinzA metadata is consistent', () {
    final m = F0033SprottLinzA();
    expect(m.metadata.id, m.id);
  });
}
