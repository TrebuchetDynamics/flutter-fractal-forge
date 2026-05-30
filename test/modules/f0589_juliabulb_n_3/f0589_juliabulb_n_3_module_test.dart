// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0589_juliabulb_n_3/f0589_juliabulb_n_3_module.dart';

void main() {
  test('F0589JuliabulbN3 instantiates', () {
    final m = F0589JuliabulbN3();
    expect(m.id, 'f0589_juliabulb_n_3');
    expect(m.shader, 'shaders/f0589_juliabulb_n_3_gpu.frag');
  });

  test('F0589JuliabulbN3 presets are well-formed', () {
    final m = F0589JuliabulbN3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0589JuliabulbN3 metadata is consistent', () {
    final m = F0589JuliabulbN3();
    expect(m.metadata.id, m.id);
  });
}
