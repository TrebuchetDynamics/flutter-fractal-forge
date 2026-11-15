import 'dart:typed_data';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/reference_capture.dart';
import 'support/baseline_inventory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final capture = ReferenceCapture();
  setUpAll(capture.prepare);
  tearDownAll(capture.finish);

  test('variance reports equality and measured RGBA differences', () {
    final a = Uint8List.fromList([0, 0, 0, 255, 0, 0, 0, 255]);
    expect(referenceVariance(a, a)['equal'], isTrue);
    expect(
        referenceVariance(a, Uint8List.fromList([2, 0, 0, 255, 0, 4, 0, 255])),
        {
          'equal': false,
          'changed_pixels': 2,
          'max_channel_delta': 4,
          'mean_absolute_channel_delta': 0.75,
        });
  });

  // Independent tests give each real rasterization its own bounded deadline.
  for (final stateId in referenceStates) {
    test('source-bound reference readback: $stateId', () async {
      final moduleId = stateId.replaceFirst('-edited', '');
      final module =
          ModuleRegistry().modules.singleWhere((m) => m.id == moduleId);
      final descriptor = capture.baselineRecord('modules', moduleId);
      expect(module.shaderAsset, descriptor['shader_asset']);
      expect(module.dimension.name, descriptor['dimension']);
      // Current defaults are independently checked by the candidate inventory
      // in prepare(); historical assertions always use original retained inputs.
      expect(retainedDefaultPreset(moduleId).toJson()..remove('createdAt'), {
        ...capture.baselineRecord('presets', moduleId)['default'] as Map,
        'params': retainedDefaultPreset(moduleId).params,
      });
      final preset = referencePreset(module, stateId);
      expect(preset.moduleId, moduleId);
      expect(preset.params, {
        ...retainedDefaultPreset(moduleId).params,
      });
      final inputs = referenceInputs(module, preset);
      expect(inputs['transparent_background'], isFalse);
      expect(inputs['time'], 0);
      if (stateId.endsWith('-edited')) {
        expect(inputs['view'],
            isNot(retainedDefaultPreset(moduleId).toJson()['view']));
      }
      if (moduleId == 'milnor_brieskorn') {
        expect(
            capture.baselineRecord('capabilities', moduleId)['mathematics']
                ['qualification'],
            contains('Inspired'));
      }
      capture.accept(
          stateId, module, preset, await drawReference(module, preset));
    });
  }
}
