// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0057_thomas_attractor/f0057_thomas_attractor_module.dart';

void main() {
  test('F0057ThomasAttractor instantiates', () {
    final m = F0057ThomasAttractor();
    expect(m.id, 'f0057_thomas_attractor');
    expect(m.shader, 'shaders/f0057_thomas_attractor_gpu.frag');
  });

  test('F0057ThomasAttractor presets are well-formed', () {
    final m = F0057ThomasAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0057ThomasAttractor metadata is consistent', () {
    final m = F0057ThomasAttractor();
    expect(m.metadata.id, m.id);
  });
}
