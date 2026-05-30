// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0086_sprott_jafari_no_equilibrium/f0086_sprott_jafari_no_equilibrium_module.dart';

void main() {
  test('F0086SprottJafariNoEquilibrium instantiates', () {
    final m = F0086SprottJafariNoEquilibrium();
    expect(m.id, 'f0086_sprott_jafari_no_equilibrium');
    expect(m.shader, 'shaders/f0086_sprott_jafari_no_equilibrium_gpu.frag');
  });

  test('F0086SprottJafariNoEquilibrium presets are well-formed', () {
    final m = F0086SprottJafariNoEquilibrium();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0086SprottJafariNoEquilibrium metadata is consistent', () {
    final m = F0086SprottJafariNoEquilibrium();
    expect(m.metadata.id, m.id);
  });
}
