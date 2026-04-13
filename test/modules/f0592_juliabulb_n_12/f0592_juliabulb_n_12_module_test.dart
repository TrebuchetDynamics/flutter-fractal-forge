// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0592_juliabulb_n_12/f0592_juliabulb_n_12_module.dart';

void main() {
  test('F0592JuliabulbN12 instantiates', () {
    final m = F0592JuliabulbN12();
    expect(m.id, 'f0592_juliabulb_n_12');
    expect(m.shader, 'shaders/f0592_juliabulb_n_12_gpu.frag');
  });

  test('F0592JuliabulbN12 presets are well-formed', () {
    final m = F0592JuliabulbN12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0592JuliabulbN12 metadata is consistent', () {
    final m = F0592JuliabulbN12();
    expect(m.metadata.id, m.id);
  });
}
