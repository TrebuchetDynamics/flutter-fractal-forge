// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1093_zaslavsky_tight/f1093_zaslavsky_tight_module.dart';

void main() {
  test('F1093ZaslavskyTight instantiates', () {
    final m = F1093ZaslavskyTight();
    expect(m.id, 'f1093_zaslavsky_tight');
    expect(m.shader, 'shaders/f1093_zaslavsky_tight_gpu.frag');
  });

  test('F1093ZaslavskyTight presets are well-formed', () {
    final m = F1093ZaslavskyTight();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1093ZaslavskyTight metadata is consistent', () {
    final m = F1093ZaslavskyTight();
    expect(m.metadata.id, m.id);
  });
}
