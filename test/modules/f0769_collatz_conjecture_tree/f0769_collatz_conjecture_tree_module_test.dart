// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0769_collatz_conjecture_tree/f0769_collatz_conjecture_tree_module.dart';

void main() {
  test('F0769CollatzConjectureTree instantiates', () {
    final m = F0769CollatzConjectureTree();
    expect(m.id, 'f0769_collatz_conjecture_tree');
    expect(m.shader, 'shaders/f0769_collatz_conjecture_tree_gpu.frag');
  });

  test('F0769CollatzConjectureTree presets are well-formed', () {
    final m = F0769CollatzConjectureTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0769CollatzConjectureTree metadata is consistent', () {
    final m = F0769CollatzConjectureTree();
    expect(m.metadata.id, m.id);
  });
}
