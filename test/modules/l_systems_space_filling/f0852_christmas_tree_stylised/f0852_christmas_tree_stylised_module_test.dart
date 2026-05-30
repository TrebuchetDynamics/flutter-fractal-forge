// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0852_christmas_tree_stylised/f0852_christmas_tree_stylised_module.dart';

void main() {
  test('F0852ChristmasTreeStylised instantiates', () {
    final m = F0852ChristmasTreeStylised();
    expect(m.id, 'f0852_christmas_tree_stylised');
    expect(m.shader, 'shaders/f0852_christmas_tree_stylised_gpu.frag');
  });

  test('F0852ChristmasTreeStylised presets are well-formed', () {
    final m = F0852ChristmasTreeStylised();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0852ChristmasTreeStylised metadata is consistent', () {
    final m = F0852ChristmasTreeStylised();
    expect(m.metadata.id, m.id);
  });
}
