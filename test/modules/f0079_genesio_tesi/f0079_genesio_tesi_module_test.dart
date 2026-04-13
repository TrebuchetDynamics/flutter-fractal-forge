// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0079_genesio_tesi/f0079_genesio_tesi_module.dart';

void main() {
  test('F0079GenesioTesi instantiates', () {
    final m = F0079GenesioTesi();
    expect(m.id, 'f0079_genesio_tesi');
    expect(m.shader, 'shaders/f0079_genesio_tesi_gpu.frag');
  });

  test('F0079GenesioTesi presets are well-formed', () {
    final m = F0079GenesioTesi();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0079GenesioTesi metadata is consistent', () {
    final m = F0079GenesioTesi();
    expect(m.metadata.id, m.id);
  });
}
