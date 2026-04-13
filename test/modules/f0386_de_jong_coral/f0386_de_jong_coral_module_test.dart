// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0386_de_jong_coral/f0386_de_jong_coral_module.dart';

void main() {
  test('F0386DeJongCoral instantiates', () {
    final m = F0386DeJongCoral();
    expect(m.id, 'f0386_de_jong_coral');
    expect(m.shader, 'shaders/f0386_de_jong_coral_gpu.frag');
  });

  test('F0386DeJongCoral presets are well-formed', () {
    final m = F0386DeJongCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0386DeJongCoral metadata is consistent', () {
    final m = F0386DeJongCoral();
    expect(m.metadata.id, m.id);
  });
}
