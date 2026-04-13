// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0271_fudgeflake/f0271_fudgeflake_module.dart';

void main() {
  test('F0271Fudgeflake instantiates', () {
    final m = F0271Fudgeflake();
    expect(m.id, 'f0271_fudgeflake');
    expect(m.shader, 'shaders/f0271_fudgeflake_gpu.frag');
  });

  test('F0271Fudgeflake presets are well-formed', () {
    final m = F0271Fudgeflake();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0271Fudgeflake metadata is consistent', () {
    final m = F0271Fudgeflake();
    expect(m.metadata.id, m.id);
  });
}
