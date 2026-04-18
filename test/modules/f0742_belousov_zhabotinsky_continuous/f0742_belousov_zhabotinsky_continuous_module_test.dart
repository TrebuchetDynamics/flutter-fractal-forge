// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0742_belousov_zhabotinsky_continuous/f0742_belousov_zhabotinsky_continuous_module.dart';

void main() {
  test('F0742BelousovZhabotinskyContinuous instantiates', () {
    final m = F0742BelousovZhabotinskyContinuous();
    expect(m.id, 'f0742_belousov_zhabotinsky_continuous');
    expect(m.shader, 'shaders/f0742_belousov_zhabotinsky_continuous_gpu.frag');
  });

  test('F0742BelousovZhabotinskyContinuous presets are well-formed', () {
    final m = F0742BelousovZhabotinskyContinuous();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0742BelousovZhabotinskyContinuous metadata is consistent', () {
    final m = F0742BelousovZhabotinskyContinuous();
    expect(m.metadata.id, m.id);
  });
}
