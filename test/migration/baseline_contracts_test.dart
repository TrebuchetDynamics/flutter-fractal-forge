import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';
import 'support/provenance_transition.dart';

List<Map<String, dynamic>> records(Map<String, Object?> document) =>
    ((document['payload'] as Map)['records'] as List)
        .cast<Map<String, dynamic>>();

void main() {
  test(
      'baseline accounts for live descriptors, round trips and exports deterministically',
      () {
    final fixtures = {
      for (final name in baselineNames)
        name: File('migration/baseline/$name.json'),
    };
    final before = {
      for (final entry in fixtures.entries)
        entry.key:
            entry.value.existsSync() ? entry.value.readAsStringSync() : null,
    };
    final first = buildBaselineInventory();
    final second = buildBaselineInventory();
    for (final name in baselineNames) {
      final encoded = canonicalJson(first[name]);
      expect(canonicalJson(second[name]), encoded,
          reason: '$name export drift');
      expect(canonicalJson(jsonDecode(encoded)), encoded);
      verifyProvenanceTransition(
          name, before[name]!, first[name]!, readProvenanceTransition());
    }

    final registry = ModuleRegistry();
    final repository = CatalogRepository.fromRegistry(registry);
    final live = {
      for (final module in registry.modules) module.id: module,
      for (final entry in repository.entries) entry.module.id: entry.module,
    };
    final moduleRecords = records(first['modules']!);
    expect(moduleRecords.map((r) => r['id']).toSet(), live.keys.toSet());
    expect(
        moduleRecords
            .expand((r) => (r['catalog'] as List))
            .map((r) => r['id'])
            .toSet(),
        repository.allIds());
    for (var i = 0; i < registry.modules.length; i++) {
      expect(
          moduleRecords.singleWhere(
              (r) => r['id'] == registry.modules[i].id)['registry_order'],
          i);
    }
    for (final name in ['parameters', 'presets', 'capabilities']) {
      expect(records(first[name]!).map((r) => r['module_id']).toSet(),
          live.keys.toSet());
    }
    final decoded = jsonDecode(canonicalJson(first));
    for (final record in records(first['parameters']!)) {
      final parameters = live[record['module_id']]!.parameters;
      final exported = record['parameters'] as List;
      expect(exported.length, parameters.length);
      for (var i = 0; i < parameters.length; i++) {
        final parameter = parameters[i];
        expect(exported[i]['default'], parameter.defaultValue);
        expect(exported[i]['options'].map((o) => o['value']).toList(),
            parameter.options.map((o) => o.value).toList());
        if (parameter.type == FractalParamType.decimalInteger) {
          final roundTripped =
              (decoded['parameters']['payload']['records'] as List)
                  .singleWhere((r) => r['module_id'] == record['module_id']);
          expect(roundTripped['parameters'][i]['default'],
              allOf(isA<String>(), parameter.defaultValue));
        }
      }
    }
    for (final record in records(first['presets']!)) {
      final module = live[record['module_id']]!;
      expect(record['default'],
          module.defaultPreset.toJson()..remove('createdAt'));
      final builtIn = record['built_in'] as List;
      expect(builtIn.length, module.builtInPresets.length);
      for (var i = 0; i < builtIn.length; i++) {
        expect(builtIn[i], {
          'order': i,
          ...module.builtInPresets[i].toJson()..remove('createdAt')
        });
      }
    }
    exportBaseline(first);
    for (final name in baselineNames) {
      expect(
          fixtures[name]!.existsSync()
              ? fixtures[name]!.readAsStringSync()
              : null,
          before[name],
          reason: 'Exports must never promote fixtures implicitly');
    }
  });

  test(
      'provenance rejects unauthorized maps, semantic drift and custody tampering',
      () {
    final before = File('migration/baseline/modules.json').readAsStringSync();
    final current = buildBaselineInventory()['modules']!;
    final transition = readProvenanceTransition();
    Map<String, dynamic> copy(Object value) =>
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
    for (final mutation in [
      'changed',
      'added',
      'removed',
      'semantic',
      'metadata',
      'transition',
      'fixture'
    ]) {
      final changed = copy(current);
      final sidecar = copy(transition);
      final sources = changed['provenance']['sources'] as Map;
      final maps = sidecar['binding_maps']['modules']['after'] as Map;
      const path = 'fdroid/flutter.version';
      if (mutation == 'changed') {
        sources[path] = maps[path] = 'unauthorized';
      } else if (mutation == 'added') {
        sources['unlisted.dart'] = maps['unlisted.dart'] = 'unauthorized';
      } else if (mutation == 'removed') {
        sources.remove(path);
        maps.remove(path);
      } else if (mutation == 'semantic') {
        changed['payload']['records'].removeLast();
      } else if (mutation == 'metadata') {
        changed['provenance']['registry_mode'] = 'different';
      } else if (mutation == 'transition') {
        maps['pubspec.lock'] = 'mismatch';
      }
      expect(
          () => verifyProvenanceTransition('modules',
              mutation == 'fixture' ? '$before ' : before, changed, sidecar),
          throwsStateError,
          reason: mutation);
    }
    expect(
        () => verifyProvenanceTransition('modules', before, current, transition,
            originalBytes: '{}'),
        throwsStateError);
  });

  test(
      'inventory detects ID, asset, default and binding drift without certifying opaque ABIs',
      () {
    final original = ModuleRegistry().byId('mandelbrot');
    Map<String, Map<String, Object?>> inventory(FractalModule module,
            {String Function(String)? source}) =>
        buildBaselineInventory(
          modules: [module],
          repository: CatalogRepository.fromFamilies(coreModules: [module]),
          readSource: source,
        );
    final baseline = inventory(original);
    final parameter = original.parameters.first;
    for (final mutation in ['id', 'asset', 'default']) {
      final changed = FractalModule(
        id: mutation == 'id' ? 'changed_identity' : original.id,
        displayName: original.displayName,
        dimension: original.dimension,
        shaderAsset: mutation == 'asset'
            ? 'shaders/diagnostic/diag_sampler.frag'
            : original.shaderAsset,
        parameters: mutation != 'default'
            ? original.parameters
            : [
                FractalParameter(
                  id: parameter.id,
                  label: parameter.label,
                  type: parameter.type,
                  min: parameter.min,
                  max: parameter.max,
                  step: parameter.step,
                  defaultValue: 12345,
                  options: parameter.options,
                  control: parameter.control,
                ),
                ...original.parameters.skip(1),
              ],
        defaultPreset: original.defaultPreset,
        builtInPresets: original.builtInPresets,
        setUniforms: original.setUniforms,
      );
      final changedInventory = inventory(changed);
      final kind = mutation == 'default' ? 'parameters' : 'modules';
      expect(canonicalJson(changedInventory[kind]!['payload']),
          isNot(canonicalJson(baseline[kind]!['payload'])),
          reason: mutation);
    }
    final bindingDrift = inventory(original, source: (path) {
      final source = File(path).readAsStringSync();
      return path == original.shaderAsset
          ? source.replaceFirst('uniform float', 'uniform vec2')
          : source;
    });
    expect(canonicalJson(bindingDrift['shader-contracts']!['payload']),
        isNot(canonicalJson(baseline['shader-contracts']!['payload'])));

    final contract = shaderDeclarations(
        'fixture.frag',
        (path) => {
              'fixture.frag':
                  '#include "slots.glsl"\nuniform sampler2D texture;\nuniform float tail;',
              'slots.glsl': 'uniform vec2 resolution;',
            }[path]!);
    expect(contract['includes'], ['slots.glsl']);
    expect(contract['float_slot_count'], 3);
    expect(contract['float_slots'], [
      {'name': 'resolution', 'type': 'vec2', 'slot': 0, 'width': 2},
      {'name': 'tail', 'type': 'float', 'slot': 2, 'width': 1},
    ]);
    expect(contract['samplers'], [
      {'name': 'texture', 'type': 'sampler2D', 'binding': 0},
    ]);
    final unsupported =
        shaderDeclarations('custom.frag', (_) => 'uniform float slots[4];');
    expect(unsupported['status'], 'unresolved');
    expect(unsupported['float_slot_count'], isNull);
    expect(unsupported['unresolved'], contains(contains('custom.frag')));
    for (final shader in records(baseline['shader-contracts']!)) {
      expect(shader['dart_setter_abi']['status'], 'unresolved');
      expect(shader['dart_setter_abi']['shader_source_path'], shader['asset']);
    }
  });
}
