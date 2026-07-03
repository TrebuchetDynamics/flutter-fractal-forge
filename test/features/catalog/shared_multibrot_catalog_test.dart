import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_multibrot_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Multibrot exponent identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedMultibrotCatalogEntries, hasLength(20));
    for (final entry in sharedMultibrotCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['power'], entry.power);
    }
  });

  test('keeps generic Multibrot d=3 configured with power uniform', () {
    final module = ModuleRegistry().byId('multibrot3');

    expect(module.defaultPreset.params['power'], 3.0);
  });

  test('locks z^19 power and caps random iterations', () {
    final module = ModuleRegistry().byId('f0094_multibrot_z_19');
    final paramsById = {for (final param in module.parameters) param.id: param};
    final view = module.defaultPreset.view;

    expect(module.defaultPreset.params['iterations'], 240);
    expect(module.defaultPreset.params['power'], 19.0);
    expect(paramsById['iterations']!.max, 320);
    expect(paramsById['power']!.min, 19.0);
    expect(paramsById['power']!.max, 19.0);
    expect(view.pan.x, closeTo(-0.0008405148983001709, 1e-12));
    expect(view.pan.y, closeTo(-0.09912946820259094, 1e-12));
  });
}
