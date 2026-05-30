// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0252_sierpinski_gasket_arrowhead/f0252_sierpinski_gasket_arrowhead_module.dart';

void main() {
  test('F0252SierpinskiGasketArrowhead instantiates', () {
    final m = F0252SierpinskiGasketArrowhead();
    expect(m.id, 'f0252_sierpinski_gasket_arrowhead');
    expect(m.shader, 'shaders/f0252_sierpinski_gasket_arrowhead_gpu.frag');
  });

  test('F0252SierpinskiGasketArrowhead presets are well-formed', () {
    final m = F0252SierpinskiGasketArrowhead();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0252SierpinskiGasketArrowhead metadata is consistent', () {
    final m = F0252SierpinskiGasketArrowhead();
    expect(m.metadata.id, m.id);
  });
}
