import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hand-built module default preset provenance', () {
    late final ModuleRegistry registry;

    setUpAll(() {
      registry = ModuleRegistry();
    });

    // Modules whose defaultPreset previously baked a non-deterministic
    // createdAt (DateTime.now()) or a hand-typed timestamp, now routed through
    // the shared catalogPreset factory.
    const fixedModuleIds = <String>[
      'julia',
      'julia_dual',
      'nova',
      'phoenix',
      'mandelbulb',
      'mandelbox',
      'gpu_gradient',
      'gpu_sampler_diag',
    ];

    test('default presets use the stable builtInPresetCreatedAt marker', () {
      final offenders = <String>[];
      for (final id in fixedModuleIds) {
        final module = registry.byId(id);
        final createdAt = module.defaultPreset.createdAt;
        if (createdAt != builtInPresetCreatedAt) {
          offenders.add('$id -> $createdAt');
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Built-in module default presets must use builtInPresetCreatedAt '
            '(not DateTime.now() or a hand-typed instant):\n${offenders.join('\n')}',
      );
    });

    test('default presets are flagged as built-in', () {
      for (final id in fixedModuleIds) {
        expect(registry.byId(id).defaultPreset.isBuiltIn, isTrue,
            reason: '$id default preset should be built-in');
      }
    });
  });
}
