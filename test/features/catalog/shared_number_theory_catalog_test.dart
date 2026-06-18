import 'package:flutter_fractals/core/modules/builders/shared_number_theory_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed parameterized Weierstrass formula identity', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedNumberTheoryCatalogEntries, hasLength(1));
    final entry = sharedNumberTheoryCatalogEntries.single;
    final module = modulesById[entry.id];

    expect(module, isNotNull);
    expect(
      module!.shaderAsset,
      'shaders/trigonometric_and_transcendental/special_functions/weierstrass_function_gpu.frag',
    );
    expect(module.defaultPreset.moduleId, entry.id);
    expect(module.defaultPreset.params['a'], entry.a);
    expect(module.defaultPreset.params['b'], entry.b);
  });

  test('keeps generic Weierstrass module configured with a and b uniforms', () {
    final module = ModuleRegistry().byId('weierstrass_function');

    expect(module.defaultPreset.params['a'], 0.5);
    expect(module.defaultPreset.params['b'], 7.0);
  });
}
