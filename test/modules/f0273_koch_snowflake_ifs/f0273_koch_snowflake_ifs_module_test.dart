// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0273_koch_snowflake_ifs/f0273_koch_snowflake_ifs_module.dart';

void main() {
  test('F0273KochSnowflakeIfs instantiates', () {
    final m = F0273KochSnowflakeIfs();
    expect(m.id, 'f0273_koch_snowflake_ifs');
    expect(m.shader, 'shaders/f0273_koch_snowflake_ifs_gpu.frag');
  });

  test('F0273KochSnowflakeIfs presets are well-formed', () {
    final m = F0273KochSnowflakeIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0273KochSnowflakeIfs metadata is consistent', () {
    final m = F0273KochSnowflakeIfs();
    expect(m.metadata.id, m.id);
  });
}
