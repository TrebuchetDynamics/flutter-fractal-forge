import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FractalController clamps boolean params: non-bool -> false (table-driven)', () {
    final boolModule = FractalModule(
      id: 'bool-module',
      displayName: (_) => 'Bool',
      dimension: FractalDimension.twoD,
      shaderAsset: 'shaders/unused.frag',
      parameters: [
        FractalParameter(
          id: 'flag',
          label: (_) => 'Flag',
          type: FractalParamType.boolean,
          min: 0,
          max: 1,
          step: 1,
          defaultValue: true,
        ),
      ],
      defaultPreset: FractalPreset(
        id: 'bool-default',
        moduleId: 'bool-module',
        name: 'Default',
        params: const {'flag': true},
        view: FractalViewState.initial(),
        createdAt: DateTime(2026, 1, 1),
        isBuiltIn: true,
      ),
      builtInPresets: const [],
      setUniforms: (_, __, ___, ____) {},
    );

    final registry = ModuleRegistry();
    // Ensure our module is selected by default.
    registry.modules.insert(0, boolModule);

    final controller = FractalController(registry);
    expect(controller.module.id, 'bool-module');

    final cases = <({Object input, bool expected})>[
      (input: true, expected: true),
      (input: false, expected: false),
      (input: 1, expected: false),
      (input: 'true', expected: false),
    ];

    for (final c in cases) {
      controller.updateParam('flag', c.input);
      expect(
        controller.params['flag'],
        c.expected,
        reason: 'input=${c.input}',
      );
    }
  });
}
