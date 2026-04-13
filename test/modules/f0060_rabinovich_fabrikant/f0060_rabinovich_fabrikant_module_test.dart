// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0060_rabinovich_fabrikant/f0060_rabinovich_fabrikant_module.dart';

void main() {
  test('F0060RabinovichFabrikant instantiates', () {
    final m = F0060RabinovichFabrikant();
    expect(m.id, 'f0060_rabinovich_fabrikant');
    expect(m.shader, 'shaders/f0060_rabinovich_fabrikant_gpu.frag');
  });

  test('F0060RabinovichFabrikant presets are well-formed', () {
    final m = F0060RabinovichFabrikant();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0060RabinovichFabrikant metadata is consistent', () {
    final m = F0060RabinovichFabrikant();
    expect(m.metadata.id, m.id);
  });
}
