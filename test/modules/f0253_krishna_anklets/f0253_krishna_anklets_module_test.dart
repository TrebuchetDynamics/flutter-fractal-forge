// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0253_krishna_anklets/f0253_krishna_anklets_module.dart';

void main() {
  test('F0253KrishnaAnklets instantiates', () {
    final m = F0253KrishnaAnklets();
    expect(m.id, 'f0253_krishna_anklets');
    expect(m.shader, 'shaders/f0253_krishna_anklets_gpu.frag');
  });

  test('F0253KrishnaAnklets presets are well-formed', () {
    final m = F0253KrishnaAnklets();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0253KrishnaAnklets metadata is consistent', () {
    final m = F0253KrishnaAnklets();
    expect(m.metadata.id, m.id);
  });
}
