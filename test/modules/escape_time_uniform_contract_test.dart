import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';

void main() {
  test('escape-time shaders expose slots for declared extra params', () {
    final failures = <String>[];

    for (final config in escapeTimeCatalog) {
      if (config.extraParams.isEmpty) continue;

      final shaderFile = File(config.shaderAsset);
      expect(
        shaderFile.existsSync(),
        isTrue,
        reason: 'Shader asset missing for ${config.id}: ${config.shaderAsset}',
      );

      final floatSlotCount = _countFlutterFloatSlots(shaderFile.readAsStringSync());
      final requiredSlots =
          EscapeTimeUniformSlots.extraStart + config.extraParams.length;
      if (floatSlotCount < requiredSlots) {
        failures.add(
          '${config.id} declares ${config.extraParams.length} extra params but '
          '${config.shaderAsset} exposes $floatSlotCount float slots; '
          'requires at least $requiredSlots.',
        );
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

int _countFlutterFloatSlots(String shaderSource) {
  const slotWidths = {
    'float': 1,
    'int': 1,
    'bool': 1,
    'vec2': 2,
    'vec3': 3,
    'vec4': 4,
  };
  final uniformPattern = RegExp(r'uniform\s+(float|int|bool|vec2|vec3|vec4)\s+\w+');
  return uniformPattern
      .allMatches(shaderSource)
      .map((match) => slotWidths[match.group(1)]!)
      .fold<int>(0, (sum, width) => sum + width);
}
