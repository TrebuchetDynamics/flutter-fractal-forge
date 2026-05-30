// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1070_tyler_rose/f1070_tyler_rose_module.dart';

void main() {
  test('F1070TylerRose instantiates', () {
    final m = F1070TylerRose();
    expect(m.id, 'f1070_tyler_rose');
    expect(m.shader, 'shaders/f1070_tyler_rose_gpu.frag');
  });

  test('F1070TylerRose presets are well-formed', () {
    final m = F1070TylerRose();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1070TylerRose metadata is consistent', () {
    final m = F1070TylerRose();
    expect(m.metadata.id, m.id);
  });
}
