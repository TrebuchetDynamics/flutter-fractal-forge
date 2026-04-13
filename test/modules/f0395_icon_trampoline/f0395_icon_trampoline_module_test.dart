// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0395_icon_trampoline/f0395_icon_trampoline_module.dart';

void main() {
  test('F0395IconTrampoline instantiates', () {
    final m = F0395IconTrampoline();
    expect(m.id, 'f0395_icon_trampoline');
    expect(m.shader, 'shaders/f0395_icon_trampoline_gpu.frag');
  });

  test('F0395IconTrampoline presets are well-formed', () {
    final m = F0395IconTrampoline();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0395IconTrampoline metadata is consistent', () {
    final m = F0395IconTrampoline();
    expect(m.metadata.id, m.id);
  });
}
