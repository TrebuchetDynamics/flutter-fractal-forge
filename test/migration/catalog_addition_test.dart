import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/performance_fractal_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';
import 'support/provenance_transition.dart';
import 'support/visual_presentation_evolution.dart';

const _id = 'synthetic_catalog_module';
const _shader = 'shaders/synthetic_catalog_module.frag';
const _source = 'lib/features/catalog/data/synthetic_catalog_module.dart';
const _catalog = 'lib/features/catalog/data/catalog_repository.dart';

Map _copy(Map value) => jsonDecode(jsonEncode(value)) as Map;
List<Map> _records(Map doc) => (doc['payload']['records'] as List).cast<Map>();
void _seal(Map stage) => stage['candidate_identity'] = visualHash({
      for (final key in [
        'binding_maps',
        'semantic_deltas',
        'compiled_artifacts',
        'kind',
        'added_module_ids',
        'added_paths',
        'changed_paths',
      ])
        key: stage[key],
    });

void main() {
  late List<Map> history;
  late Map addition;
  late Map<String, Map<String, Object?>> inventory;
  late String laterId;
  String beforeBytes(String name) {
    final dir = switch (name) {
      'param-interpolation' ||
      'physical-events' ||
      'randomization' =>
        'oracles',
      _ => 'baseline',
    };
    return File('migration/$dir/$name.json').readAsStringSync();
  }

  Map priorDocument(String name) =>
      evolveVisualDocument(name, jsonDecode(beforeBytes(name)) as Map, history);
  setUpAll(() {
    history = orderedVisualStages(readVisualStages());
    final registry = ModuleRegistry();
    final original = registry.modules.first;
    final module = FractalModule(
      id: _id,
      displayName: (_) => 'Synthetic module',
      dimension: original.dimension,
      shaderAsset: _shader,
      parameters: original.parameters,
      defaultPreset: original.defaultPreset.copyWith(moduleId: _id),
      builtInPresets: const [],
      setUniforms: original.setUniforms,
    );
    laterId = registry.modules[1].id;
    final modules = [...registry.modules]..insert(1, module);
    const newSources = {
      _source: '// Synthetic catalog module source\n',
      _shader:
          '#include <flutter/runtime_effect.glsl>\nuniform vec2 uResolution;\n',
    };
    String readSource(String path) {
      if (newSources.containsKey(path)) return newSources[path]!;
      final contents = File(path).readAsStringSync();
      return switch (path) {
        _catalog => "import 'synthetic_catalog_module.dart';\n$contents",
        'pubspec.yaml' =>
          contents.replaceFirst('  shaders:\n', '  shaders:\n    - $_shader\n'),
        _ => contents,
      };
    }

    inventory = buildBaselineInventory(
      modules: modules,
      repository: CatalogRepository.fromFamilies(
        coreModules: modules,
        performanceModules: PerformanceFractalCatalog.buildModules(),
      ),
      readSource: readSource,
    );
    final inventorySources =
        (inventory['modules']!['provenance'] as Map)['sources'] as Map;
    final prior = history.last['binding_maps'] as Map;
    addition = {
      'schema': 1,
      'task': syntheticCatalogAdditionTask,
      'base_revision': history.last['base_revision'],
      'kind': 'catalog-addition',
      'added_module_ids': [_id],
      'added_paths': [_source, _shader],
      'changed_paths': [_catalog, 'pubspec.yaml'],
      'binding_maps': {
        for (final name in prior.keys)
          name: {
            'before': _copy(prior[name]['after'] as Map),
            'after': {
              ...prior[name]['after'] as Map,
              for (final path in [_catalog, 'pubspec.yaml'])
                if ((prior[name]['after'] as Map).containsKey(path))
                  path: inventorySources[path],
              _source: inventorySources[_source],
              if (baselineNames.contains(name) || name == 'reference')
                _shader: inventorySources[_shader],
            },
          },
      },
      'semantic_deltas': {
        for (final name in baselineNames) name: _records(inventory[name]!)
      },
      'compiled_artifacts': [],
    };
    _seal(addition);
  });

  test('catalog receipt evolves real inventories and binds all eleven maps',
      () {
    final stages = [...history, addition];
    final maps = addition['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final name in maps.keys.cast<String>()) {
      expect((maps[name]['before'] as Map).containsKey(_source), isFalse);
      expect(maps[name]['after'][_source], isNotNull);
      if (name == 'reference')
        continue; // Uses the separate source chain below.
      final bytes = beforeBytes(name);
      // The addition may change bindings, but not the data as of its parent.
      final generated = inventory[name] ??
          <String, Object?>{
            ...priorDocument(name).cast<String, Object?>(),
            'source_bindings': maps[name]['after'],
          };
      verifyBoundDocument(name, bytes, generated, visualStages: stages);
    }
    final provenance = readProvenanceStages();
    verifySourceStages(
        'reference',
        provenance.first['binding_maps']['reference']['before'] as Map,
        maps['reference']['after'] as Map,
        stages: [...stages.reversed, ...provenance.reversed]);
    Map later(Map doc) => _records(doc).singleWhere((r) => r['id'] == laterId);
    final before = later(priorDocument('modules'));
    final after = later(inventory['modules']!);
    expect(after['registry_order'], (before['registry_order'] as int) + 1);
    expect(after['catalog'][0]['order'],
        (before['catalog'][0]['order'] as int) + 1);
  });

  test('catalog receipt rejects changes to retained inventory records', () {
    for (final (name, key, value) in <(String, String, Object)>[
      ('modules', 'display_name_en', 'changed'),
      ('parameters', 'parameters', []),
      ('presets', 'default', {}),
      ('capabilities', 'native_cpu', 'changed'),
      ('shader-contracts', 'float_slot_count', -1),
    ]) {
      final bad = _copy(addition);
      final records = (bad['semantic_deltas'][name] as List).cast<Map>();
      final old = records.firstWhere((r) =>
          r['id'] != _id && r['module_id'] != _id && r['asset'] != _shader);
      old[key] = value;
      _seal(bad);
      expect(
          () => evolveVisualDocument(name, priorDocument(name), [bad]),
          throwsA(isA<StateError>().having((e) => e.message, 'message',
              contains('catalog addition changes existing records in $name'))));
    }
  });

  for (final mutation in [
    'undeclared ID',
    'removed module',
    'missing added ID',
    'existing order',
    'non-dense order'
  ]) {
    test('catalog receipt rejects $mutation', () {
      final bad = _copy(addition);
      final list = (bad['semantic_deltas']['modules'] as List).cast<Map>();
      final added = list.singleWhere((r) => r['id'] == _id);
      final previous = list.singleWhere((r) => r['registry_order'] == 0);
      final later = list.singleWhere((r) => r['id'] == laterId);
      final before = priorDocument('modules');
      var expected = 'catalog addition changes existing records in modules';
      switch (mutation) {
        case 'undeclared ID':
          list.add({
            ...added,
            'id': 'zz_undeclared',
            'registry_order': list.length,
            'catalog': [
              {
                ...added['catalog'][0] as Map,
                'id': 'core:zz_undeclared',
                'order': list.length
              },
            ],
          });
        case 'removed module':
          list.remove(
              list.singleWhere((r) => r['registry_order'] == list.length - 1));
        case 'missing added ID':
          list.remove(added);
          expected = 'catalog addition missing declared module ID';
        case 'existing order':
          previous['registry_order'] = later['registry_order'];
          later['registry_order'] = 0;
        case 'non-dense order':
          added['catalog'][0]['order'] = -1;
          expected = 'catalog addition non-dense order';
      }
      _seal(bad);
      expect(
          () => evolveVisualDocument('modules', before, [bad]),
          throwsA(isA<StateError>()
              .having((e) => e.message, 'message', contains(expected))));
    });
  }

  test('catalog receipt rejects an unchanged binding map', () {
    final bad = _copy(addition);
    final record = bad['binding_maps']['state-replay'] as Map;
    record['after'] = _copy(record['before'] as Map);
    _seal(bad);
    expect(
        () => validateVisualStage(bad),
        throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains(
                'catalog addition did not update state-replay bindings'))));
  });

  for (final mutation in [
    'unlisted addition',
    'unlisted change',
    'unchanged declaration',
    'removed path',
    'widened policy',
    'missing map',
    'unbound shader'
  ]) {
    test('catalog receipt rejects $mutation', () {
      final bad = _copy(addition);
      final maps = bad['binding_maps'] as Map;
      final after = maps['physical-events']['after'] as Map;
      switch (mutation) {
        case 'unlisted addition':
          after['unlisted.dart'] = 'a' * 64;
        case 'unlisted change':
          after['pubspec.lock'] = 'a' * 64;
        case 'unchanged declaration':
          for (final record in maps.values) {
            record['after'][_catalog] = record['before'][_catalog];
          }
        case 'removed path':
          after.remove(_catalog);
        case 'widened policy':
          after['pubspec.lock'] = 'a' * 64;
          (bad['changed_paths'] as List).add('pubspec.lock');
        case 'missing map':
          maps.remove('physical-events');
        case 'unbound shader':
          (maps['shader-contracts']['after'] as Map).remove(_shader);
      }
      _seal(bad);
      expect(() => validateVisualStage(bad), throwsStateError);
    });
  }
}
