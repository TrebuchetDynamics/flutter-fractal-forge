import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

void main() {
  group('buildEscapeTimeModule', () {
    test('built-in generated presets are replayable', () {
      const config = EscapeTimeConfig(
        id: 'replayable-test',
        name: 'Replayable Test',
        shaderAsset: 'shaders/replayable_test.frag',
      );

      final first = buildEscapeTimeModule(config);
      final second = buildEscapeTimeModule(config);

      expect(first.defaultPreset.createdAt, DateTime.utc(2025, 1, 1));
      expect(second.defaultPreset.createdAt, first.defaultPreset.createdAt);
      expect(
        first.builtInPresets.map((preset) => preset.createdAt),
        everyElement(first.defaultPreset.createdAt),
      );
    });
  });
}
