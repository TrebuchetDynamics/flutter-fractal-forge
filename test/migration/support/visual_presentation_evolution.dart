import 'dart:convert';
import 'dart:io';

// Existing locked test dependencies.
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

import 'baseline_inventory.dart' show baselineNames, canonicalJson;

const visualStageRoot = 'migration/oracles/visual-presentation';
const visualPilotIds = [
  'mandelbrot',
  'burning_ship',
  'newton_z3',
  'mandelbulb',
  'mandelbox',
];
const visualFixture = 'test/shaders/sculptural_surface_fixture.frag';
const visualProofTask = 'VISUAL-RICHNESS-PROOF';
const visualSurfaceTask = 'VISUAL-RICHNESS-SCULPTURAL-SURFACE';
const visualDefaultsTask = 'VISUAL-RICHNESS-CURATED-DEFAULTS';
const shaderCacheRecoveryTask = 'SHADER-CACHE-RECOVERY-01';
const viewerExportStateTask = 'VIEWER-EXPORT-STATE-01';
const presetBatchExportTask = 'PRESET-BATCH-EXPORT-26';
const viewerExportIntegrationTask = 'PR24-VIEWER-EXPORT-INTEGRATION';
const phoneSliderTask = 'PHONE-SINGLE-SLIDER-32';
const directEditControlsTask = 'DIRECT-EDIT-CONTROLS-31';
const overlayHitTargetsTask = 'OVERLAY-HIT-TARGETS-34';
const startupDeepLinksTask = 'STARTUP-DEEP-LINKS-51';
const cpuRenderParamsTask = 'CPU-RENDER-PARAMS-57';
const stateMachineFixesTask = 'STATE-MACHINE-FIXES-49-60';
const catalogAdditionSupportTask = 'CATALOG-ADDITION-SUPPORT-63';
const recamanArcsTask = 'RECAMAN-ARCS-64';
const zetaCriticalStripTask = 'ZETA-CRITICAL-STRIP-65';
const juliaUniformOrderTask = 'JULIA-UNIFORM-ORDER-71';
const escapeTimeUniformDefaultsTask = 'ESCAPE-TIME-UNIFORM-DEFAULTS-72';
const perturbationOrbitCacheKeyTask = 'PERTURBATION-ORBIT-CACHE-KEY-74';
const historyReplayModuleIdTask = 'HISTORY-REPLAY-MODULE-ID-75';

// This stage may only append these inputs in shader order and add their
// defaults to the generated Default/Classic presets. Existing data is fixed.
const _escapeTimeUniformDefaults = <String, Map<String, double>>{
  'halley': {'relaxation': 1.0},
  'schroeder': {'relaxation': 1.0},
  'newton_z4': {'relaxation': 1.0},
  'newton_z5': {'relaxation': 1.0},
  'newton_z6': {'relaxation': 1.0},
  'bedhead': {'paramA': -0.81, 'paramB': -0.92},
  'chebyshev_halley_param': {'lambda': 0.0},
  'fractal_dream': {
    'paramA': 1.468,
    'paramB': 2.407,
    'paramC': 0.194,
    'paramD': 1.438
  },
  'gray_scott_rd': {'feedRate': 0.04, 'killRate': 0.06, 'scale': 5.0},
  'jason_rampe_1': {'paramA': 1.7, 'paramB': 1.7, 'paramC': 0.6, 'paramD': 1.2},
  'king': {'beta': 0.5},
  'magnetic_pendulum': {'friction': 0.01},
  'orbit_trap_point': {'trapReal': 0.0, 'trapImag': 0.0},
  'orbit_trap_ring': {'ringRadius': 0.01},
  'picard_mann_newton': {'alpha': 0.5},
  'symmetric_icon': {'lambda': 2.409, 'alpha': -2.5, 'symmetryOrder': 5.0},
  'traub_ostrowski': {'alpha': 1.0},
  'weierstrass_elliptic': {'g2': 4.0},
  'f0534_weierstrass_elliptic': {'g2': 4.0},
};
const syntheticCatalogAdditionTask = 'SYNTHETIC-CATALOG-ADDITION';

// Each real catalog addition must register its own exact policy here.
const _catalogAdditionPolicies = {
  recamanArcsTask: {
    'added_module_ids': ['recaman_arcs'],
    'added_paths': [
      'lib/core/modules/fractals/recaman_arcs_module.dart',
      'shaders/number_theory/recaman_arcs_gpu.frag',
    ],
    'changed_paths': [
      'lib/core/modules/fractal_mathematics.dart',
      'lib/core/modules/module_registry.dart',
      'lib/l10n/app_localizations.dart',
      'lib/l10n/app_localizations_en.dart',
      'lib/l10n/app_localizations_es.dart',
      'pubspec.yaml',
      'test/migration/support/visual_presentation_evolution.dart',
    ],
  },
  zetaCriticalStripTask: {
    'added_module_ids': ['zeta_critical_strip'],
    'added_paths': [
      'lib/core/modules/fractals/zeta_critical_strip_module.dart',
      'shaders/number_theory/zeta_critical_strip_gpu.frag',
    ],
    'changed_paths': [
      'lib/core/modules/fractal_mathematics.dart',
      'lib/core/modules/module_registry.dart',
      'lib/features/renderer/cpu/formulas/cpu_formulas.dart',
      'lib/features/viewer/rendering/cpu_fallback_pane.dart',
      'lib/l10n/app_localizations.dart',
      'lib/l10n/app_localizations_en.dart',
      'lib/l10n/app_localizations_es.dart',
      'pubspec.yaml',
      'test/migration/support/visual_presentation_evolution.dart',
    ],
  },
  syntheticCatalogAdditionTask: {
    'added_module_ids': ['synthetic_catalog_module'],
    'added_paths': [
      'lib/features/catalog/data/synthetic_catalog_module.dart',
      'shaders/synthetic_catalog_module.frag',
    ],
    'changed_paths': [
      'lib/features/catalog/data/catalog_repository.dart',
      'pubspec.yaml',
    ],
  },
};
const _catalogStageKeys = {
  'kind',
  'added_module_ids',
  'added_paths',
  'changed_paths',
};
bool isCatalogAdditionTask(Object? task) =>
    _catalogAdditionPolicies.containsKey(task);

const _equal = DeepCollectionEquality();
const _proofPaths = [
  'test/migration/visual_presentation_evolution_test.dart',
  'test/migration/support/visual_presentation_evolution.dart',
  'test/migration/support/baseline_inventory.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/reference_capture.dart',
  'test/migration/reference_render_test.dart',
  'test/migration/support/randomization_oracle.dart',
  'test/migration/randomization_oracle_test.dart',
];
const _surfacePaths = [
  'lib/features/viewer/fractal_viewer_screen.dart',
  'shaders/shared/surface_lighting.glsl',
  'lib/core/modules/builders/raymarched_3d/builder.dart',
  'lib/core/controllers/fractal_controller.dart',
  'test/migration/support/physical_events_oracle.dart',
  'test/migration/support/visual_presentation_evolution.dart',
  'shaders/legacy/raymarched_3d/mandelbulb.frag',
  'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
  'lib/core/modules/fractals/mandelbulb_module.dart',
  'lib/core/modules/fractals/mandelbox_module.dart',
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_es.dart',
  visualFixture,
  'pubspec.yaml',
];
const _shaderCacheRecoveryPaths = [
  'lib/features/renderer/widgets/renderer/shaders/shader_loader.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _viewerExportStatePaths = [
  'lib/features/viewer/diagnostics/gpu_health_probe.dart',
  'lib/features/viewer/diagnostics/viewer_gpu_health.dart',
  'lib/features/viewer/export/viewer_export_actions.dart',
  'lib/features/viewer/fractal_viewer_screen.dart',
  'lib/features/viewer/navigation/viewer_interactions.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _viewerExportIntegrationPaths = [
  ..._viewerExportStatePaths,
  'lib/features/viewer/export/viewer_export_session.dart',
];
const _presetBatchExportPaths = [
  'lib/core/services/export/batch_export_service.dart',
  'lib/core/services/storage/preset_store.dart',
  'lib/features/export/batch_export_dialog.dart',
  'lib/features/presets/preset_sheet.dart',
  'lib/features/viewer/dialogs/viewer_dialogs.dart',
  'lib/features/viewer/fractal_viewer_screen.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _phoneSliderPaths = [
  'lib/features/viewer/chrome/fractal_controls_hud.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _directEditControlsPaths = [
  'lib/features/viewer/chrome/fractal_view_controls.dart',
  'lib/features/viewer/chrome/viewer_tools.dart',
  'lib/features/viewer/fractal_viewer_screen.dart',
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_es.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _overlayHitTargetsPaths = [
  'lib/features/presets/preset_sheet.dart',
  'lib/features/viewer/export/viewer_export_overlay.dart',
  'lib/features/viewer/rendering/compare_renderer.dart',
  'lib/shared/widgets/app_bottom_sheet.dart',
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_es.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _startupDeepLinksPaths = [
  'lib/core/services/platform/deep_link_service.dart',
  'lib/core/services/rendering/palette/palette_service.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _cpuRenderParamsPaths = [
  'lib/features/renderer/cpu/cpu_fractal_renderer.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _stateMachineFixesPaths = [
  'lib/core/controllers/fractal_controller.dart',
  'lib/features/looper/looper_controller.dart',
  'lib/features/renderer/widgets/renderer/fractal_renderer.dart',
  'lib/features/renderer/widgets/renderer/input/gesture_handler.dart',
  'lib/features/viewer/diagnostics/gpu_health_probe.dart',
  'lib/features/viewer/diagnostics/viewer_gpu_health.dart',
  'lib/features/viewer/fractal_viewer_screen.dart',
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _catalogAdditionSupportPaths = [
  'test/migration/support/provenance_transition.dart',
  'test/migration/support/visual_presentation_evolution.dart',
];
const _defaultsPaths = [
  'lib/core/modules/builders/escape_time_catalog/families/core_escape_time_family.dart',
  'lib/core/modules/builders/escape_time_catalog/families/convergent_root_finding.dart',
  'lib/core/modules/builders/escape_time/builder.dart',
  'lib/core/modules/builders/built_in_preset_contract.dart',
];

String visualHash(Object? value) =>
    sha256.convert(utf8.encode(canonicalJson(value))).toString();
void visualRequire(bool condition, String message) {
  if (!condition) throw StateError('Visual presentation: $message');
}

Map _copy(Map value) => jsonDecode(jsonEncode(value)) as Map;
List<Map> readVisualStages() {
  final directory = Directory(visualStageRoot);
  final archive = Directory('$visualStageRoot/archived-candidates');
  final archived = validateVisualArchive({
    if (archive.existsSync())
      for (final entry in archive.listSync(recursive: true, followLinks: false))
        entry.path.substring(archive.path.length + 1):
            entry is File ? entry.readAsBytesSync() : <int>[],
  });
  final files = directory.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final stages = [
    for (final file in files) jsonDecode(file.readAsStringSync()) as Map
  ];
  visualRequire(!stages.any((s) => s['task'] == syntheticCatalogAdditionTask),
      'synthetic catalog addition cannot be loaded from disk');
  final historical = orderedVisualStages([
    ...stages.where(
        (s) => [visualProofTask, shaderCacheRecoveryTask].contains(s['task'])),
    archived,
  ]);
  visualRequire(
      _equal.equals(historical.map((s) => s['task']).toList(),
          [visualProofTask, shaderCacheRecoveryTask, viewerExportStateTask]),
      'exact archived historical chain');
  return stages;
}

/// The one historical sibling is mandatory custody, never an active DAG edge.
Map validateVisualArchive(Map<String, List<int>> entries) {
  visualRequire(
      _equal.equals(entries.keys.toSet(), {'viewer-export-state.json'}),
      'exact archived candidate inventory');
  final bytes = entries['viewer-export-state.json']!;
  visualRequire(
      sha256.convert(bytes).toString() ==
          '6487cb8d58956c4610c60b39fc9b33d8939af3db24bc98bbdf9023192a2663e7',
      'archived candidate raw hash');
  final stage = jsonDecode(utf8.decode(bytes)) as Map;
  visualRequire(
      stage['task'] == viewerExportStateTask &&
          stage['base_revision'] == '92a36981966eddc4b48a6d7c6820bf39e7e8ac25',
      'archived candidate identity');
  validateVisualStage(stage);
  return stage;
}

/// Complete maps are evidence, not a wildcard for future paths or hashes.
void validateVisualStage(Map stage) {
  final catalogPolicy = _catalogAdditionPolicies[stage['task']];
  visualRequire(
      _equal.equals(stage.keys.toSet(), {
        'schema',
        'task',
        'base_revision',
        'binding_maps',
        'semantic_deltas',
        'compiled_artifacts',
        'candidate_identity',
        if (catalogPolicy != null) ..._catalogStageKeys,
      }),
      'stage keys');
  if (catalogPolicy != null) {
    visualRequire(stage['kind'] == 'catalog-addition', 'catalog addition kind');
    for (final entry in catalogPolicy.entries) {
      visualRequire(_equal.equals(stage[entry.key], entry.value),
          'catalog addition policy ${entry.key}');
    }
  }
  final allowed = switch (stage['task']) {
    visualProofTask => _proofPaths,
    visualSurfaceTask => _surfacePaths,
    visualDefaultsTask => _defaultsPaths,
    shaderCacheRecoveryTask => _shaderCacheRecoveryPaths,
    viewerExportStateTask => _viewerExportStatePaths,
    presetBatchExportTask => _presetBatchExportPaths,
    viewerExportIntegrationTask => _viewerExportIntegrationPaths,
    phoneSliderTask => _phoneSliderPaths,
    directEditControlsTask => _directEditControlsPaths,
    overlayHitTargetsTask => _overlayHitTargetsPaths,
    startupDeepLinksTask => _startupDeepLinksPaths,
    cpuRenderParamsTask => _cpuRenderParamsPaths,
    stateMachineFixesTask => _stateMachineFixesPaths,
    catalogAdditionSupportTask => _catalogAdditionSupportPaths,
    juliaUniformOrderTask => const [
        'lib/core/modules/builders/escape_time/builder.dart',
        'lib/core/modules/builders/escape_time_catalog/families/kaleidoscopes.dart',
        'test/migration/support/provenance_transition.dart',
        'test/migration/support/visual_presentation_evolution.dart',
      ],
    escapeTimeUniformDefaultsTask => const [
        'lib/core/modules/builders/escape_time_catalog/families/convergent_root_finding.dart',
        'lib/core/modules/builders/escape_time_catalog/families/kaleidoscopes.dart',
        'lib/core/modules/builders/escape_time_catalog/families/rational_polynomial.dart',
        'lib/core/modules/builders/escape_time_catalog/research_batches/batch_14_extensions.dart',
        'lib/core/modules/builders/shared_catalogs/shared_exact_escape_catalog.dart',
        'test/migration/support/provenance_transition.dart',
        'test/migration/support/visual_presentation_evolution.dart',
      ],
    perturbationOrbitCacheKeyTask => const [
        'lib/core/modules/escape_time_perturb_module.dart',
        'test/migration/support/provenance_transition.dart',
        'test/migration/support/visual_presentation_evolution.dart',
      ],
    historyReplayModuleIdTask => const [
        'lib/core/controllers/fractal_controller.dart',
        'test/migration/support/provenance_transition.dart',
        'test/migration/support/visual_presentation_evolution.dart',
      ],
    _ when catalogPolicy != null => const <String>[],
    _ => throw StateError('Visual presentation: unknown task ${stage['task']}'),
  };
  visualRequire(
      stage['schema'] == 1 &&
          RegExp(r'^[a-f0-9]{40}$').hasMatch(stage['base_revision'] as String),
      'stage identity');
  final maintenance = stage['task'] == shaderCacheRecoveryTask ||
      stage['task'] == viewerExportStateTask ||
      stage['task'] == presetBatchExportTask ||
      stage['task'] == viewerExportIntegrationTask ||
      stage['task'] == phoneSliderTask ||
      stage['task'] == directEditControlsTask ||
      stage['task'] == overlayHitTargetsTask ||
      stage['task'] == startupDeepLinksTask ||
      stage['task'] == cpuRenderParamsTask ||
      stage['task'] == stateMachineFixesTask ||
      stage['task'] == catalogAdditionSupportTask ||
      stage['task'] == perturbationOrbitCacheKeyTask ||
      stage['task'] == historyReplayModuleIdTask;
  final maps = stage['binding_maps'] as Map;
  visualRequire(
      _equal.equals(maps.keys.toSet(), {
        'modules',
        'parameters',
        'presets',
        'capabilities',
        'shader-contracts',
        'state-replay',
        'precision-replay',
        'param-interpolation',
        'physical-events',
        'randomization',
        'reference',
      }),
      'complete map inventory');
  var changed = false;
  final addedPaths = <String>{};
  final changedPaths = <String>{};
  for (final entry in maps.entries) {
    final record = entry.value as Map;
    visualRequire(_equal.equals(record.keys.toSet(), {'before', 'after'}),
        'binding record keys');
    final before = record['before'] as Map, after = record['after'] as Map;
    visualRequire(before.isNotEmpty && after.isNotEmpty, 'empty bindings');
    for (final map in [before, after]) {
      visualRequire(
          map.keys.every((k) => k is String) &&
              map.values.every(
                  (v) => v is String && RegExp(r'^[a-f0-9]{64}$').hasMatch(v)),
          'binding hash format');
    }
    visualRequire(before.keys.toSet().difference(after.keys.toSet()).isEmpty,
        'removed binding');
    // These oracles follow the controller's local import graph. The
    // physical-events oracle already reached both files through the viewer.
    final addedAliases = stage['task'] == historyReplayModuleIdTask &&
            const {
              'state-replay',
              'precision-replay',
              'param-interpolation',
              'randomization',
              'reference',
            }.contains(entry.key)
        ? const {
            'lib/core/services/storage/preset_store.dart',
            'lib/core/services/storage/preset_storage_slot.dart',
          }
        : const <String>{};
    if (maintenance ||
        stage['task'] == juliaUniformOrderTask ||
        stage['task'] == escapeTimeUniformDefaultsTask) {
      visualRequire(
          _equal.equals(
              after.keys.toSet().difference(before.keys.toSet()), addedAliases),
          'maintenance binding key sets');
    }
    if (catalogPolicy != null) {
      visualRequire(!catalogPolicy['added_paths']!.any(before.containsKey),
          'catalog addition path already bound');
      visualRequire(!_equal.equals(before, after),
          'catalog addition did not update ${entry.key} bindings');
    }
    for (final key in after.keys.cast<String>()) {
      if (before[key] == after[key]) continue;
      changed = true;
      if (addedAliases.contains(key)) continue;
      if (catalogPolicy == null) {
        visualRequire(allowed.contains(key), 'undeclared path $key');
      } else if (before.containsKey(key)) {
        visualRequire(catalogPolicy['changed_paths']!.contains(key),
            'undeclared path $key');
        changedPaths.add(key);
      } else {
        visualRequire(catalogPolicy['added_paths']!.contains(key),
            'undeclared path $key');
        addedPaths.add(key);
      }
    }
  }
  visualRequire(changed, 'blank approval record');
  final deltas = stage['semantic_deltas'] as Map;
  if (catalogPolicy != null) {
    visualRequire(
        _equal.equals(addedPaths, catalogPolicy['added_paths']!.toSet()) &&
            _equal.equals(
                changedPaths, catalogPolicy['changed_paths']!.toSet()),
        'catalog addition declared paths must all change');
    _validateCatalogAdditionRecords(
        deltas,
        catalogPolicy['added_module_ids']!.toSet(),
        addedPaths,
        maps['shader-contracts']['after'] as Map);
  } else {
    visualRequire(
        deltas.keys.every((k) => [
              'parameters',
              'presets',
              'shader-contracts',
              if (stage['task'] == escapeTimeUniformDefaultsTask)
                'capabilities',
            ].contains(k)),
        'undeclared semantic document');
  }
  if (stage['task'] == visualProofTask) {
    visualRequire(deltas.isEmpty, 'proof cannot change semantics');
  }
  if (maintenance) {
    visualRequire(deltas.isEmpty, 'maintenance cannot change semantics');
    visualRequire((stage['compiled_artifacts'] as List).isEmpty,
        'maintenance cannot change compiled artifacts');
  }
  for (final artifact in (stage['compiled_artifacts'] as List).cast<Map>()) {
    visualRequire(
        stage['task'] == visualSurfaceTask &&
            _equal.equals(artifact.keys.toSet(), {
              'asset',
              'source_sha256',
              'compiled_sha256',
              'backend_sha256',
            }) &&
            _surfacePaths.contains(artifact['asset']) &&
            (artifact['asset'] as String).endsWith('.frag'),
        'compiled artifact keys');
    visualRequire(
        maps['reference']['after'][artifact['asset']] ==
            artifact['source_sha256'],
        'artifact source binding');
    for (final key in ['source_sha256', 'compiled_sha256', 'backend_sha256']) {
      visualRequire(RegExp(r'^[a-f0-9]{64}$').hasMatch(artifact[key] as String),
          'artifact hash');
    }
  }
  visualRequire(
      stage['candidate_identity'] ==
          visualHash({
            'binding_maps': maps,
            'semantic_deltas': deltas,
            'compiled_artifacts': stage['compiled_artifacts'],
            if (catalogPolicy != null)
              for (final key in _catalogStageKeys) key: stage[key],
          }),
      'candidate identity');
}

String _inventoryRecordKey(String name) => switch (name) {
      'modules' => 'id',
      'shader-contracts' => 'asset',
      _ => 'module_id',
    };

Set<String> _addedAssets(Map deltas, Set<String> ids) =>
    (deltas['modules'] as List)
        .cast<Map>()
        .where((r) => ids.contains(r['id']))
        .map((r) => r['shader_asset'] as String)
        .toSet();

void _validateCatalogAdditionRecords(
    Map deltas, Set<String> ids, Set<String> addedPaths, Map shaderBindings) {
  visualRequire(_equal.equals(deltas.keys.toSet(), baselineNames.toSet()),
      'catalog addition requires all five inventories');
  for (final name in baselineNames) {
    final records = deltas[name];
    final key = _inventoryRecordKey(name);
    visualRequire(
        records is List && records.every((r) => r is Map && r[key] is String),
        'catalog addition record IDs in $name');
    final keys = (records as List).map((r) => r[key] as String).toList();
    final sorted = keys.toSet().toList()..sort();
    visualRequire(_equal.equals(keys, sorted),
        'catalog addition record IDs must be unique and sorted in $name');
    if (name != 'shader-contracts') {
      visualRequire(keys.toSet().containsAll(ids),
          'catalog addition missing declared module ID in $name');
    }
  }
  final modules = (deltas['modules'] as List)
      .cast<Map>()
      .where((r) => ids.contains(r['id']));
  final idsByAsset = <String, List<String>>{};
  for (final module in modules) {
    final asset = module['shader_asset'];
    visualRequire(
        asset is String &&
            addedPaths.contains(asset) &&
            shaderBindings.containsKey(asset),
        'catalog addition module requires a new bound shader asset');
    (idsByAsset[asset as String] ??= []).add(module['id'] as String);
  }
  final contracts = {
    for (final contract in (deltas['shader-contracts'] as List).cast<Map>())
      contract['asset']: contract,
  };
  for (final entry in idsByAsset.entries) {
    visualRequire(
        _equal.equals(contracts[entry.key]?['module_ids'], entry.value),
        'catalog addition shader contract membership for ${entry.key}');
  }
}

/// The optional registration is one shader-list addition, not a pubspec waiver.
void validateVisualFixtureRegistration(String before, String after) {
  final old = jsonDecode(jsonEncode(loadYaml(before))) as Map;
  final next = jsonDecode(jsonEncode(loadYaml(after))) as Map;
  final assets = next['flutter']['shaders'] as List;
  visualRequire(
      !((old['flutter']['shaders'] as List).contains(visualFixture)) &&
          assets.where((a) => a == visualFixture).length == 1,
      'exactly one named fixture registration');
  assets.remove(visualFixture);
  visualRequire(_equal.equals(old, next), 'unlisted pubspec change');
}

/// Order complete bundles, not individual maps (which may be identities).
/// Semantics must follow the very same uniquely adjacent source chain.
List<Map> orderedVisualStages(List<Map> stages) {
  if (stages.isEmpty) return [];
  final pending = [...stages];
  visualRequire(pending.map((s) => s['task']).toSet().length == pending.length,
      'duplicate candidate task');
  for (final stage in pending) {
    validateVisualStage(stage);
  }
  Map bundle(Map stage, String edge) => {
        for (final name in (stage['binding_maps'] as Map).keys)
          name: stage['binding_maps'][name][edge],
      };
  final roots = pending
      .where((stage) => !pending.any((other) =>
          _equal.equals(bundle(other, 'after'), bundle(stage, 'before'))))
      .toList();
  visualRequire(roots.length == 1, 'broken/ambiguous candidate bundle root');
  var cursor = bundle(roots.single, 'before');
  final seen = [cursor];
  final ordered = <Map>[];
  while (pending.isNotEmpty) {
    final adjacent = pending
        .where((s) => _equal.equals(bundle(s, 'before'), cursor))
        .toList();
    visualRequire(
        adjacent.length == 1, 'broken/ambiguous candidate bundle adjacency');
    final stage = adjacent.single;
    cursor = bundle(stage, 'after');
    visualRequire(!seen.any((s) => _equal.equals(s, cursor)),
        'cyclic candidate bundle adjacency');
    seen.add(cursor);
    ordered.add(stage);
    pending.remove(stage);
  }
  return ordered;
}

/// Historical stages have already validated their own immutable policy.
void validateVisualSourceChain(
    String name, Map historical, Map current, List<Map> stages) {
  Map cursor = historical;
  final ordered = orderedVisualStages(stages);
  for (final stage in ordered) {
    final record = stage['binding_maps'][name] as Map;
    if (name == 'shader-contracts' &&
        stage['task'] == visualSurfaceTask &&
        record['before']['pubspec.yaml'] != record['after']['pubspec.yaml']) {
      final original = Process.runSync('timeout',
          ['10', 'git', 'show', '${stage['base_revision']}:pubspec.yaml']);
      visualRequire(original.exitCode == 0,
          'cannot read base pubspec: ${original.stderr}');
      final before = original.stdout as String;
      final after = File('pubspec.yaml').readAsStringSync();
      visualRequire(
          sha256.convert(utf8.encode(before)).toString() ==
                  record['before']['pubspec.yaml'] &&
              sha256.convert(utf8.encode(after)).toString() ==
                  record['after']['pubspec.yaml'],
          'stale pubspec source binding');
      validateVisualFixtureRegistration(before, after);
    }
  }
  for (final stage in ordered) {
    visualRequire(_equal.equals(stage['binding_maps'][name]['before'], cursor),
        'broken stage adjacency for $name');
    cursor = stage['binding_maps'][name]['after'] as Map;
  }
  visualRequire(
      _equal.equals(cursor, current), 'stale candidate bindings $name');
}

Object? _at(Object? document, List<String> path) {
  for (final key in path) {
    document =
        document is List ? document[int.parse(key)] : (document as Map)[key];
  }
  return document;
}

bool _allowedDelta(String name, Map document, Map delta, String task) {
  final path = (delta['path'] as String).split('/').skip(1).toList();
  if (path.length < 4 || path[0] != 'payload' || path[1] != 'records')
    return false;
  final records = document['payload']['records'] as List;
  final index = int.tryParse(path[2]);
  if (index == null || index < 0 || index >= records.length) return false;
  final record = records[index] as Map;
  final id = record['module_id'];
  if (task == juliaUniformOrderTask) {
    if (id != 'mandel_julia_dual') return false;
    if (name == 'parameters' && path.length == 4 && path[3] == 'parameters') {
      final sibling =
          records.singleWhere((r) => r['module_id'] == 'julia_dual');
      final juliaC = (sibling['parameters'] as List)
          .where((p) => p['id'] == 'juliaCReal' || p['id'] == 'juliaCImag');
      return _equal
          .equals(delta['after'], [...record['parameters'], ...juliaC]);
    }
    if (name != 'presets' ||
        !(path.length == 5 && path[3] == 'default' && path[4] == 'params' ||
            path.length == 6 &&
                path[3] == 'built_in' &&
                path[4] == '0' &&
                path[5] == 'params')) {
      return false;
    }
    final params = _at(document, path) as Map;
    return !params.containsKey('juliaCReal') &&
        !params.containsKey('juliaCImag') &&
        _equal.equals(delta['after'], {
          ...params,
          'juliaCReal': -0.7269,
          'juliaCImag': 0.1889,
        });
  }
  if (task == escapeTimeUniformDefaultsTask) {
    if (name == 'capabilities') {
      if (id != 'halley' || path.length != 5 || path[3] != 'mathematics') {
        return false;
      }
      return switch (path[4]) {
        'qualification' => delta['after'] ==
            'Source-reviewed update; color does not prove convergence',
        'default_formula' => delta['after'] ==
            "z(n+1) = z - 1.0*2*f*f'/(2*f'^2 - f*f''); f(z) = z^3 - 1; regularized division",
        _ => false,
      };
    }
    final defaults = _escapeTimeUniformDefaults[id];
    if (defaults == null) return false;
    final after = delta['after'];
    if (name == 'parameters' && path.length == 4 && path[3] == 'parameters') {
      final before = record['parameters'] as List;
      if (after is! List ||
          after.length != before.length + defaults.length ||
          !_equal.equals(after.take(before.length).toList(), before)) {
        return false;
      }
      var index = before.length;
      for (final entry in defaults.entries) {
        final param = after[index];
        if (param is! Map ||
            param['order'] != index ||
            param['id'] != entry.key ||
            param['default'] != entry.value ||
            before.any((p) => p['id'] == entry.key)) {
          return false;
        }
        index++;
      }
      return true;
    }
    if (name != 'presets' ||
        !(path.length == 5 && path[3] == 'default' && path[4] == 'params' ||
            path.length == 6 &&
                path[3] == 'built_in' &&
                path[4] == '0' &&
                path[5] == 'params')) {
      return false;
    }
    final params = _at(document, path) as Map;
    return !defaults.keys.any(params.containsKey) &&
        _equal.equals(after, {...params, ...defaults});
  }
  final ids = task == visualSurfaceTask
      ? ['mandelbulb', 'mandelbox']
      : task == visualDefaultsTask
          ? visualPilotIds.take(3).toList()
          : [];
  if (!ids.contains(id)) return false;
  if (name == 'presets') {
    if (path[3] != 'default') return false;
    if (path.length == 6 && path[4] == 'params' && path[5] == 'colorScheme') {
      final value = delta['after'];
      return value is num &&
          value == value.roundToDouble() &&
          value >= 0 &&
          value <=
              (id == 'mandelbulb'
                  ? 4
                  : id == 'mandelbox'
                      ? 8
                      : 63) &&
          (task != visualSurfaceTask || value == (id == 'mandelbulb' ? 4 : 8));
    }
    return path.length == 6 &&
        path[4] == 'view' &&
        ['zoom', 'panX', 'panY', 'rotX', 'rotY', 'rotZ'].contains(path[5]) &&
        delta['after'] is num &&
        (delta['after'] as num).isFinite &&
        (path[5] != 'zoom' || (delta['after'] as num) > 0);
  }
  if (name != 'parameters' || path.length != 6 || path[3] != 'parameters')
    return false;
  final parameter = _at(document, path.take(5).toList()) as Map;
  if (parameter['id'] != 'colorScheme') return false;
  if (task == visualDefaultsTask) {
    final value = delta['after'];
    return path[5] == 'default' &&
        value is num &&
        value == value.roundToDouble() &&
        value >= (parameter['min'] as num) &&
        value <= (parameter['max'] as num);
  }
  final max = id == 'mandelbulb' ? 4 : 8;
  if (path[5] == 'max')
    return delta['before'] == max - 1 && delta['after'] == max;
  if (path[5] != 'options') return false;
  final old = delta['before'] as List, next = delta['after'] as List;
  return next.length == old.length + 1 &&
      _equal.equals(next.take(old.length).toList(), old) &&
      _equal.equals(next.last, {'value': max, 'label_en': 'Sculptural'});
}

/// Only one named test fixture may be appended; production contracts stay exact.
Map visualFixtureContract() => {
      'asset': visualFixture,
      'declared_in_pubspec': true,
      'module_ids': <String>[],
      'status': 'declarations_resolved',
      'includes': ['flutter/runtime_effect.glsl'],
      'float_slots': [
        {'name': 'uResolution', 'type': 'vec2', 'slot': 0, 'width': 2},
        {'name': 'uCase', 'type': 'float', 'slot': 2, 'width': 1},
      ],
      'float_slot_count': 3,
      'samplers': [],
      'sampler_count': 0,
      'unresolved': [],
      'dart_setter_abi': {
        'status': 'unresolved',
        'source_path': 'lib/core/modules/module_registry.dart',
        'shader_source_path': visualFixture,
        'reason':
            'Opaque UniformSetter closures are not introspected; declarations do not certify setter compatibility or a wgpu ABI.',
      },
    };

// Rank independently of the lexical layout of the records array. Verify the
// actual order is dense before removing the inserted records, so arbitrary
// gaps or duplicate ranks cannot disappear during projection.
void _projectOrder(List<Map> records, String key, Set<Map> removed) {
  visualRequire(
      records.every((r) => r[key] is int), 'catalog addition invalid $key');
  records.sort((a, b) => (a[key] as int).compareTo(b[key] as int));
  for (var i = 0, rank = 0; i < records.length; i++) {
    final record = records[i];
    visualRequire(record[key] == i, 'catalog addition non-dense $key');
    if (!removed.contains(record)) record[key] = rank++;
  }
}

void _evolveCatalogAddition(String name, Map document, Map stage) {
  final key = _inventoryRecordKey(name);
  final ids = (stage['added_module_ids'] as List).cast<String>().toSet();
  final deltas = stage['semantic_deltas'] as Map;
  final added = name == 'shader-contracts' ? _addedAssets(deltas, ids) : ids;
  final payload = document['payload'] as Map;
  final before = (payload['records'] as List).cast<Map>();
  visualRequire(!before.any((r) => added.contains(r[key])),
      'catalog addition ID/asset already present in $name');
  final after = (deltas[name] as List).cast<Map>();
  // Copy before re-ranking; never mutate receipt records or historical bytes.
  final projected = name == 'modules' ? after.map(_copy).toList() : after;
  if (name == 'modules') {
    final removed = projected.where((r) => added.contains(r[key])).toSet();
    final allEntries = <Map>[];
    final removedEntries = <Map>{};
    final catalogIds = <String>{};
    for (final record in projected) {
      final catalog = record['catalog'];
      visualRequire(record.containsKey('registry_order') && catalog is List,
          'catalog addition invalid module order data');
      for (final entry in catalog as List) {
        visualRequire(
            entry is Map &&
                entry['id'] is String &&
                catalogIds.add(entry['id'] as String),
            'catalog addition invalid/duplicate catalog ID');
        allEntries.add(entry as Map);
        if (removed.contains(record)) removedEntries.add(entry);
      }
    }
    _projectOrder(projected.where((r) => r['registry_order'] != null).toList(),
        'registry_order', removed);
    _projectOrder(allEntries, 'order', removedEntries);
  }
  visualRequire(
      canonicalJson(projected.where((r) => !added.contains(r[key])).toList()) ==
          canonicalJson(before),
      'catalog addition changes existing records in $name; restore them before recording the addition');
  // Keep the result independent of the input stage for subsequent evolution.
  payload['records'] = jsonDecode(jsonEncode(after));
}

Map evolveVisualDocument(String name, Map historical, List<Map> stages) {
  final document = _copy(historical);
  for (final stage in orderedVisualStages(stages)) {
    if (isCatalogAdditionTask(stage['task'])) {
      if (baselineNames.contains(name))
        _evolveCatalogAddition(name, document, stage);
      continue;
    }
    for (final delta in ((stage['semantic_deltas'] as Map)[name] as List? ?? [])
        .cast<Map>()) {
      visualRequire(
          _equal.equals(delta.keys.toSet(), {'path', 'before', 'after'}),
          'semantic delta keys');
      final path = (delta['path'] as String).split('/').skip(1).toList();
      final fixture = name == 'shader-contracts' &&
          stage['task'] == visualSurfaceTask &&
          delta['path'] == '/payload/records/-';
      if (fixture) {
        final records = document['payload']['records'] as List;
        visualRequire(
            delta['before'] == null &&
                _equal.equals(delta['after'], visualFixtureContract()) &&
                !records.cast<Map>().any((r) => r['asset'] == visualFixture) &&
                stage['binding_maps'][name]['after'][visualFixture] is String &&
                stage['binding_maps'][name]['before']['pubspec.yaml'] !=
                    stage['binding_maps'][name]['after']['pubspec.yaml'],
            'only named fixture addition with source/pubspec binding');
        // Collector order is lexical by asset, not appended source order.
        records.add(delta['after']);
        records.sort(
            (a, b) => (a['asset'] as String).compareTo(b['asset'] as String));
        continue;
      }
      visualRequire(
          _allowedDelta(name, document, delta, stage['task'] as String),
          'undeclared semantic delta $name ${delta['path']}');
      visualRequire(
          _equal.equals(_at(document, path), delta['before']) &&
              !_equal.equals(delta['before'], delta['after']),
          'stale/no-op semantic delta');
      final parent = _at(document, path.take(path.length - 1).toList());
      if (parent is List) {
        parent[int.parse(path.last)] = delta['after'];
      } else {
        (parent as Map)[path.last] = delta['after'];
      }
    }
  }
  return document;
}

/// Exhaustive accounting is also tested on hosts without plugins/devices.
void validateVisualCaptureCounts(
    {required int selected,
    required int rendered,
    required int failed,
    required int skipped}) {
  visualRequire(
      selected > 0 && rendered == selected && failed == 0 && skipped == 0,
      'incomplete capture: selected=$selected rendered=$rendered failed=$failed skipped=$skipped; restore shader/plugin/export support and rerun');
}
