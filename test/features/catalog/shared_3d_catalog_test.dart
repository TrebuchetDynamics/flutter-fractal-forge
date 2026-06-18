import 'package:flutter_fractals/core/modules/builders/shared_3d_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed shared 3D parameter identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(shared3DCatalogEntries, hasLength(18));
    for (final entry in shared3DCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(module.dimension, FractalDimension.threeD);
      expect(module.defaultPreset.moduleId, entry.id);
      final key = entry.kind == Shared3DKind.mandelboxScale ? 'scale' : 'power';
      expect(module.defaultPreset.params[key], entry.value);
    }
  });

  test('does not promote duplicate Mandelbox scale identities', () {
    final ids = shared3DCatalogEntries.map((entry) => entry.id).toSet();

    expect(ids, isNot(contains('f0579_mandelbox_s_1_5')));
    expect(ids, isNot(contains('f0580_mandelbox_s_2_0')));
    expect(ids, isNot(contains('f0581_mandelbox_s_2_5')));
    expect(ids, isNot(contains('f0582_mandelbox_s_3_0')));
  });
}
