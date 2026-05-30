// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1086_bogdanov_birth/f1086_bogdanov_birth_module.dart';

void main() {
  test('F1086BogdanovBirth instantiates', () {
    final m = F1086BogdanovBirth();
    expect(m.id, 'f1086_bogdanov_birth');
    expect(m.shader, 'shaders/f1086_bogdanov_birth_gpu.frag');
  });

  test('F1086BogdanovBirth presets are well-formed', () {
    final m = F1086BogdanovBirth();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1086BogdanovBirth metadata is consistent', () {
    final m = F1086BogdanovBirth();
    expect(m.metadata.id, m.id);
  });
}
