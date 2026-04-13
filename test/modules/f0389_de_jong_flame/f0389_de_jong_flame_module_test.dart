// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0389_de_jong_flame/f0389_de_jong_flame_module.dart';

void main() {
  test('F0389DeJongFlame instantiates', () {
    final m = F0389DeJongFlame();
    expect(m.id, 'f0389_de_jong_flame');
    expect(m.shader, 'shaders/f0389_de_jong_flame_gpu.frag');
  });

  test('F0389DeJongFlame presets are well-formed', () {
    final m = F0389DeJongFlame();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0389DeJongFlame metadata is consistent', () {
    final m = F0389DeJongFlame();
    expect(m.metadata.id, m.id);
  });
}
