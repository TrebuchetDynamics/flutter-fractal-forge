// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0084_fitzhugh_nagumo/f0084_fitzhugh_nagumo_module.dart';

void main() {
  test('F0084FitzhughNagumo instantiates', () {
    final m = F0084FitzhughNagumo();
    expect(m.id, 'f0084_fitzhugh_nagumo');
    expect(m.shader, 'shaders/f0084_fitzhugh_nagumo_gpu.frag');
  });

  test('F0084FitzhughNagumo presets are well-formed', () {
    final m = F0084FitzhughNagumo();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0084FitzhughNagumo metadata is consistent', () {
    final m = F0084FitzhughNagumo();
    expect(m.metadata.id, m.id);
  });
}
