// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0588_juliabulb_n_8_branching/f0588_juliabulb_n_8_branching_module.dart';

void main() {
  test('F0588JuliabulbN8Branching instantiates', () {
    final m = F0588JuliabulbN8Branching();
    expect(m.id, 'f0588_juliabulb_n_8_branching');
    expect(m.shader, 'shaders/f0588_juliabulb_n_8_branching_gpu.frag');
  });

  test('F0588JuliabulbN8Branching presets are well-formed', () {
    final m = F0588JuliabulbN8Branching();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0588JuliabulbN8Branching metadata is consistent', () {
    final m = F0588JuliabulbN8Branching();
    expect(m.metadata.id, m.id);
  });
}
