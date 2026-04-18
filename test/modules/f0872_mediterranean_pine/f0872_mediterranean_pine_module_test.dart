// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0872_mediterranean_pine/f0872_mediterranean_pine_module.dart';

void main() {
  test('F0872MediterraneanPine instantiates', () {
    final m = F0872MediterraneanPine();
    expect(m.id, 'f0872_mediterranean_pine');
    expect(m.shader, 'shaders/f0872_mediterranean_pine_gpu.frag');
  });

  test('F0872MediterraneanPine presets are well-formed', () {
    final m = F0872MediterraneanPine();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0872MediterraneanPine metadata is consistent', () {
    final m = F0872MediterraneanPine();
    expect(m.metadata.id, m.id);
  });
}
