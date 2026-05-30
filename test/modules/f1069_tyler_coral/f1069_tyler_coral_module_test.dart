// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1069_tyler_coral/f1069_tyler_coral_module.dart';

void main() {
  test('F1069TylerCoral instantiates', () {
    final m = F1069TylerCoral();
    expect(m.id, 'f1069_tyler_coral');
    expect(m.shader, 'shaders/f1069_tyler_coral_gpu.frag');
  });

  test('F1069TylerCoral presets are well-formed', () {
    final m = F1069TylerCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1069TylerCoral metadata is consistent', () {
    final m = F1069TylerCoral();
    expect(m.metadata.id, m.id);
  });
}
