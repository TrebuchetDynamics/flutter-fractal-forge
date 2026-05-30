// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0587_juliabulb_n_8_classic/f0587_juliabulb_n_8_classic_module.dart';

void main() {
  test('F0587JuliabulbN8Classic instantiates', () {
    final m = F0587JuliabulbN8Classic();
    expect(m.id, 'f0587_juliabulb_n_8_classic');
    expect(m.shader, 'shaders/f0587_juliabulb_n_8_classic_gpu.frag');
  });

  test('F0587JuliabulbN8Classic presets are well-formed', () {
    final m = F0587JuliabulbN8Classic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0587JuliabulbN8Classic metadata is consistent', () {
    final m = F0587JuliabulbN8Classic();
    expect(m.metadata.id, m.id);
  });
}
