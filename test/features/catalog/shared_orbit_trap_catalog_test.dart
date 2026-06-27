import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_orbit_trap_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed orbit-trap geometry identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedOrbitTrapCatalogEntries, hasLength(24));
    for (final entry in sharedOrbitTrapCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['trapMode'], entry.trapMode);
      expect(module.parameters.any((p) => p.id == 'trapMode'), isTrue);
    }
  });

  test('keeps generic orbit-trap cross configured as trap mode zero', () {
    final module = ModuleRegistry().byId('mandelbrot_orbit_trap');

    expect(module.defaultPreset.params['trapMode'], 0);
  });

  test('keeps exact orbit-trap cross out of shared trap-mode variants', () {
    final ids = sharedOrbitTrapCatalogEntries.map((entry) => entry.id).toSet();

    expect(ids, isNot(contains('f1156_orbit_trap_cross')));
    expect(ModuleRegistry().byId('f1156_orbit_trap_cross').shaderAsset,
        'shaders/escape_time_family/orbit_and_domain/orbit_trap_cross_gpu.frag');
  });
}
