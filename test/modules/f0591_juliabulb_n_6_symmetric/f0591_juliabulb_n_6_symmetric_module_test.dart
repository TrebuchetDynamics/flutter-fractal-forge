// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0591_juliabulb_n_6_symmetric/f0591_juliabulb_n_6_symmetric_module.dart';

void main() {
  test('F0591JuliabulbN6Symmetric instantiates', () {
    final m = F0591JuliabulbN6Symmetric();
    expect(m.id, 'f0591_juliabulb_n_6_symmetric');
    expect(m.shader, 'shaders/f0591_juliabulb_n_6_symmetric_gpu.frag');
  });

  test('F0591JuliabulbN6Symmetric presets are well-formed', () {
    final m = F0591JuliabulbN6Symmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0591JuliabulbN6Symmetric metadata is consistent', () {
    final m = F0591JuliabulbN6Symmetric();
    expect(m.metadata.id, m.id);
  });
}
