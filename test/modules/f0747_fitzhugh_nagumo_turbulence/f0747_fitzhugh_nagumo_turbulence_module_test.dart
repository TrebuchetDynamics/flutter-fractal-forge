// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0747_fitzhugh_nagumo_turbulence/f0747_fitzhugh_nagumo_turbulence_module.dart';

void main() {
  test('F0747FitzhughNagumoTurbulence instantiates', () {
    final m = F0747FitzhughNagumoTurbulence();
    expect(m.id, 'f0747_fitzhugh_nagumo_turbulence');
    expect(m.shader, 'shaders/f0747_fitzhugh_nagumo_turbulence_gpu.frag');
  });

  test('F0747FitzhughNagumoTurbulence presets are well-formed', () {
    final m = F0747FitzhughNagumoTurbulence();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0747FitzhughNagumoTurbulence metadata is consistent', () {
    final m = F0747FitzhughNagumoTurbulence();
    expect(m.metadata.id, m.id);
  });
}
