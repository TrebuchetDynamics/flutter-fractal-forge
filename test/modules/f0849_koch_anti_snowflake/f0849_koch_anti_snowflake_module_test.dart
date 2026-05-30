// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0849_koch_anti_snowflake/f0849_koch_anti_snowflake_module.dart';

void main() {
  test('F0849KochAntiSnowflake instantiates', () {
    final m = F0849KochAntiSnowflake();
    expect(m.id, 'f0849_koch_anti_snowflake');
    expect(m.shader, 'shaders/f0849_koch_anti_snowflake_gpu.frag');
  });

  test('F0849KochAntiSnowflake presets are well-formed', () {
    final m = F0849KochAntiSnowflake();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0849KochAntiSnowflake metadata is consistent', () {
    final m = F0849KochAntiSnowflake();
    expect(m.metadata.id, m.id);
  });
}
