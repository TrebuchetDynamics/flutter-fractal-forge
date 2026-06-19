import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void expectSharedCoefficientCatalog({
  required Iterable<dynamic> entries,
  required int expectedLength,
  required String shaderAsset,
}) {
  final registry = ModuleRegistry();
  final modulesById = {
    for (final module in registry.modules) module.id: module
  };

  expect(entries, hasLength(expectedLength));
  final coefficients = <String>{};
  for (final entry in entries) {
    final module = modulesById[entry.id as String];

    expect(module, isNotNull, reason: entry.id as String);
    expect(module!.shaderAsset, shaderAsset);
    expect(
      File('assets/catalog_thumbs/${entry.id}.png').existsSync(),
      isTrue,
      reason: entry.id as String,
    );
    expect(module.defaultPreset.moduleId, entry.id);
    expect(module.defaultPreset.params['a'], entry.a);
    expect(module.defaultPreset.params['b'], entry.b);
    expect(module.defaultPreset.params['c'], entry.c);
    expect(module.defaultPreset.params['d'], entry.d);
    expect(
      coefficients.add('${entry.a},${entry.b},${entry.c},${entry.d}'),
      isTrue,
    );
  }
}
