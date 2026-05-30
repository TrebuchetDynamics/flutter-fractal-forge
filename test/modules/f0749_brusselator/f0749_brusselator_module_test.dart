// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0749_brusselator/f0749_brusselator_module.dart';

void main() {
  test('F0749Brusselator instantiates', () {
    final m = F0749Brusselator();
    expect(m.id, 'f0749_brusselator');
    expect(m.shader, 'shaders/f0749_brusselator_gpu.frag');
  });

  test('F0749Brusselator presets are well-formed', () {
    final m = F0749Brusselator();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0749Brusselator metadata is consistent', () {
    final m = F0749Brusselator();
    expect(m.metadata.id, m.id);
  });
}
