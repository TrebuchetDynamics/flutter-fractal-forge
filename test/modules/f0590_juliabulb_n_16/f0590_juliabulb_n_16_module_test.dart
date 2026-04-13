// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0590_juliabulb_n_16/f0590_juliabulb_n_16_module.dart';

void main() {
  test('F0590JuliabulbN16 instantiates', () {
    final m = F0590JuliabulbN16();
    expect(m.id, 'f0590_juliabulb_n_16');
    expect(m.shader, 'shaders/f0590_juliabulb_n_16_gpu.frag');
  });

  test('F0590JuliabulbN16 presets are well-formed', () {
    final m = F0590JuliabulbN16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0590JuliabulbN16 metadata is consistent', () {
    final m = F0590JuliabulbN16();
    expect(m.metadata.id, m.id);
  });
}
