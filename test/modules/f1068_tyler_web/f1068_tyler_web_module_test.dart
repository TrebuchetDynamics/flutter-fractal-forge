// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1068_tyler_web/f1068_tyler_web_module.dart';

void main() {
  test('F1068TylerWeb instantiates', () {
    final m = F1068TylerWeb();
    expect(m.id, 'f1068_tyler_web');
    expect(m.shader, 'shaders/f1068_tyler_web_gpu.frag');
  });

  test('F1068TylerWeb presets are well-formed', () {
    final m = F1068TylerWeb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1068TylerWeb metadata is consistent', () {
    final m = F1068TylerWeb();
    expect(m.metadata.id, m.id);
  });
}
