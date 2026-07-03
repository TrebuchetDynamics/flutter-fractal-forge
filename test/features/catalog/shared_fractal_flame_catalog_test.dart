import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_fractal_flame_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed supported fractal-flame variation identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedFractalFlameCatalogEntries, hasLength(41));
    for (final entry in sharedFractalFlameCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['variation'], entry.variation);
    }
  });

  test('registers the highest reviewed flame variation', () {
    final ids = ModuleRegistry().modules.map((m) => m.id).toSet();

    expect(ids, contains('f1141_fractal_flame_v40_rectangles'));
  });

  test('locks Fan variation and symmetry to reviewed defaults', () {
    final module = ModuleRegistry().byId('f1123_fractal_flame_v22_fan');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(module.defaultPreset.params['iterations'], 164);
    expect(module.defaultPreset.params['bailout'], 2.6);
    expect(module.defaultPreset.params['variation'], 22);
    expect(paramsById['variation']!.min, 22);
    expect(paramsById['variation']!.max, 22);
    expect(paramsById['symmetry']!.min, 0);
    expect(paramsById['symmetry']!.max, 0);
  });
}
