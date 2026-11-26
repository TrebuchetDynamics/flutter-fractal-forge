import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';
import 'support/provenance_transition.dart';
import 'support/visual_presentation_evolution.dart';

Map copy(Map value) => jsonDecode(jsonEncode(value)) as Map;
void seal(Map stage) => stage['candidate_identity'] = visualHash({
      for (final key in [
        'binding_maps',
        'semantic_deltas',
        'compiled_artifacts'
      ])
        key: stage[key],
    });
Map stageFor(String task) {
  final maintenance = task == shaderCacheRecoveryTask ||
      task == presetBatchExportTask ||
      task == phoneSliderTask ||
      task == directEditControlsTask ||
      task == overlayHitTargetsTask ||
      task == startupDeepLinksTask ||
      task == cpuRenderParamsTask ||
      task == stateMachineFixesTask ||
      task == catalogAdditionSupportTask;
  final prior = maintenance
      ? orderedVisualStages(readVisualStages()).last['binding_maps'] as Map
      : readProvenanceStages().last['binding_maps'] as Map;
  final stage = <String, Object?>{
    'schema': 1,
    'task': task,
    'base_revision': '08f3040d990d5df04de6c3f3834ccf30e592235a',
    'binding_maps': {
      for (final name in prior.keys)
        name: {
          'before': copy(prior[name]['after'] as Map),
          'after': copy(prior[name]['after'] as Map),
        },
    },
    'semantic_deltas': <String, Object?>{},
    'compiled_artifacts': [],
  };
  final path = task == visualSurfaceTask
      ? 'lib/core/modules/fractals/mandelbulb_module.dart'
      : task == visualDefaultsTask
          ? 'lib/core/modules/builders/escape_time_catalog/families/core_escape_time_family.dart'
          : task == directEditControlsTask
              ? 'lib/features/viewer/fractal_viewer_screen.dart'
              : task == phoneSliderTask
                  ? 'lib/features/viewer/chrome/fractal_controls_hud.dart'
                  : 'test/migration/support/provenance_transition.dart';
  (stage['binding_maps'] as Map)[maintenance ? 'physical-events' : 'presets']
      ['after'][path] = 'a' * 64;
  seal(stage);
  return stage;
}

Map retained(String name) =>
    jsonDecode(File('migration/baseline/$name.json').readAsStringSync()) as Map;
int indexOf(Map document, String id) => (document['payload']['records'] as List)
    .indexWhere((r) => r['module_id'] == id);

void main() {
  for (final task in [
    shaderCacheRecoveryTask,
    presetBatchExportTask,
    phoneSliderTask,
    directEditControlsTask,
    overlayHitTargetsTask,
    startupDeepLinksTask,
    cpuRenderParamsTask,
    stateMachineFixesTask,
    catalogAdditionSupportTask,
  ]) {
    test('$task is exact source-only maintenance with unchanged key sets', () {
      final stage = stageFor(task);
      validateVisualStage(stage);
      expect(evolveVisualDocument('presets', retained('presets'), [stage]),
          retained('presets'));
      for (final mutation in [
        'semantic',
        'compiled',
        'unrelated',
        'add-allowed',
        'remove',
        'unknown',
        'gap',
        'stale',
        'identity',
      ]) {
        final bad = copy(stage);
        final record = bad['binding_maps']['presets'] as Map;
        switch (mutation) {
          case 'semantic':
            bad['semantic_deltas']['presets'] = [];
          case 'compiled':
            bad['compiled_artifacts'] = [{}];
          case 'unrelated':
            record['after']['pubspec.lock'] = 'c' * 64;
          case 'add-allowed':
            // This path is allowlisted but absent in this collector's map.
            record['after'][
                    'lib/features/renderer/widgets/renderer/shaders/shader_loader.dart'] =
                'c' * 64;
          case 'remove':
            (record['after'] as Map).remove('pubspec.lock');
          case 'unknown':
            bad['task'] = 'SHADER-CACHE-RECOVERY-02';
          case 'gap':
            record['before']['pubspec.lock'] = 'c' * 64;
          case 'stale':
            bad['binding_maps']['physical-events']['after']
                    ['test/migration/support/provenance_transition.dart'] =
                'c' * 64;
        }
        seal(bad);
        if (mutation == 'identity') bad['candidate_identity'] = 'c' * 64;
        expect(() {
          for (final name
              in (stage['binding_maps'] as Map).keys.cast<String>()) {
            validateVisualSourceChain(
                name,
                stage['binding_maps'][name]['before'] as Map,
                stage['binding_maps'][name]['after'] as Map,
                [bad]);
          }
        }, throwsStateError, reason: mutation);
      }
    });
  }

  test('phone slider successor binds exactly HUD and provenance helpers', () {
    final stages = orderedVisualStages(readVisualStages());
    final stage = stages.singleWhere((s) => s['task'] == phoneSliderTask);
    final prior = stages[stages.indexOf(stage) - 1];
    expect(stage['task'], phoneSliderTask);
    expect(prior['task'], viewerExportIntegrationTask);
    expect(stage['base_revision'], 'b6a67e1e38c008762a6daf4d23e8154a098c3dda');
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    final maps = stage['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final id in maps.keys.cast<String>()) {
      final before = maps[id]['before'] as Map;
      final after = maps[id]['after'] as Map;
      expect(before, prior['binding_maps'][id]['after'], reason: id);
      expect(after.keys.toSet(), before.keys.toSet(), reason: id);
      final changed = before.keys.where((p) => before[p] != after[p]).toSet();
      expect(
          changed,
          {
            if (id == 'physical-events')
              'lib/features/viewer/chrome/fractal_controls_hud.dart',
            if ([
              'param-interpolation',
              'physical-events',
              'precision-replay',
              'randomization',
              'reference',
              'state-replay'
            ].contains(id)) ...[
              'test/migration/support/provenance_transition.dart',
              'test/migration/support/visual_presentation_evolution.dart',
            ],
          },
          reason: id);
      for (final path in after.keys.cast<String>()) {
        if (changed.contains(path)) {
          // Current bytes are checked only at the new terminal stage. Historical
          // receipts continue to assert their original exact source hashes.
          expect(stages.last['binding_maps'][id]['after'][path],
              sha256.convert(File(path).readAsBytesSync()).toString(),
              reason: '$id: $path');
        }
      }
      final historical = stages.take(stages.indexOf(stage) + 1).toList();
      for (final order in [historical, historical.reversed.toList()]) {
        validateVisualSourceChain(id,
            stages.first['binding_maps'][id]['before'] as Map, after, order);
      }
    }
  });

  test('direct Edit successor binds only its exact UI and policy sources', () {
    final stages = orderedVisualStages(readVisualStages());
    final stage =
        stages.singleWhere((s) => s['task'] == directEditControlsTask);
    final historical = stages.take(stages.indexOf(stage) + 1).toList();
    expect(stage['task'], directEditControlsTask);
    expect(stage['base_revision'], '8087a167cbf369b19bcff3d24394878d28c8b263');
    expect(historical[historical.length - 2]['task'], phoneSliderTask);
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    for (final id in (stage['binding_maps'] as Map).keys.cast<String>()) {
      final before = stage['binding_maps'][id]['before'] as Map;
      final after = stage['binding_maps'][id]['after'] as Map;
      expect(before,
          historical[historical.length - 2]['binding_maps'][id]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      expect(
          before.keys.where((p) => before[p] != after[p]).toSet(),
          {
            'lib/l10n/app_localizations.dart',
            'lib/l10n/app_localizations_en.dart',
            'lib/l10n/app_localizations_es.dart',
            if (id == 'physical-events') ...[
              'lib/features/viewer/chrome/fractal_view_controls.dart',
              'lib/features/viewer/chrome/viewer_tools.dart',
              'lib/features/viewer/fractal_viewer_screen.dart',
            ],
            if ([
              'param-interpolation',
              'physical-events',
              'precision-replay',
              'randomization',
              'reference',
              'state-replay'
            ].contains(id)) ...[
              'test/migration/support/provenance_transition.dart',
              'test/migration/support/visual_presentation_evolution.dart',
            ],
          },
          reason: id);
      const retainedHashes = {
        'lib/l10n/app_localizations.dart':
            'bf729e66c052277b855b36440fe1720125dd4f9358ac03ed2315b5f60c8fbe5c',
        'lib/l10n/app_localizations_en.dart':
            '2bd631a591bba20ad33c545b7d3a7de4acd19920ed597689ba5dd850790c94b9',
        'lib/l10n/app_localizations_es.dart':
            '20af13f408e4ce8ae43f0436c7b86bbda3bad53c2484261d6774e6be963f64e3',
        'test/migration/support/provenance_transition.dart':
            '9c5e65894fd164774228fe278b37007a7cc604e3e8eed6d2e05a6a3c7882db1e',
        'test/migration/support/visual_presentation_evolution.dart':
            '0cdbb662905521af1ca7b7190e097a74e24e72bb2154e51f74fddad229ddc974',
        // Changed again by STATE-MACHINE-FIXES-49-60.
        'lib/features/viewer/fractal_viewer_screen.dart':
            'd9470c4555166f74fb764e66f35f74b5bfd5ac706865bc3d40e4d9ea41f89788',
      };
      for (final path in after.keys.where((p) => before[p] != after[p])) {
        expect(
            after[path],
            retainedHashes[path] ??
                sha256
                    .convert(File(path as String).readAsBytesSync())
                    .toString());
        expect(stages.last['binding_maps'][id]['after'][path],
            sha256.convert(File(path as String).readAsBytesSync()).toString());
      }
      for (final order in [historical, historical.reversed.toList()]) {
        validateVisualSourceChain(id,
            stages.first['binding_maps'][id]['before'] as Map, after, order);
      }
    }
  });

  test('overlay targets successor binds only exact input and policy sources',
      () {
    final allStages = orderedVisualStages(readVisualStages());
    final stage =
        allStages.singleWhere((s) => s['task'] == overlayHitTargetsTask);
    final stages = allStages.take(allStages.indexOf(stage) + 1).toList();
    expect(stage['task'], overlayHitTargetsTask);
    expect(stage['base_revision'], 'cfd18a890fd2dfea5758fc68f5db03e1acbd20dc');
    expect(stages[stages.length - 2]['task'], directEditControlsTask);
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    const l10n = {
      'lib/l10n/app_localizations.dart',
      'lib/l10n/app_localizations_en.dart',
      'lib/l10n/app_localizations_es.dart',
    };
    const helpers = {
      'test/migration/support/provenance_transition.dart',
      'test/migration/support/visual_presentation_evolution.dart',
    };
    for (final id in (stage['binding_maps'] as Map).keys.cast<String>()) {
      final before = stage['binding_maps'][id]['before'] as Map;
      final after = stage['binding_maps'][id]['after'] as Map;
      expect(before, stages[stages.length - 2]['binding_maps'][id]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      final changed = before.keys.where((p) => before[p] != after[p]).toSet();
      expect(
          changed,
          {
            ...l10n,
            if (const {
              'param-interpolation',
              'physical-events',
              'precision-replay',
              'randomization',
              'reference',
              'state-replay'
            }.contains(id))
              ...helpers,
            if (id == 'physical-events') ...{
              'lib/features/presets/preset_sheet.dart',
              'lib/features/viewer/export/viewer_export_overlay.dart',
              'lib/features/viewer/rendering/compare_renderer.dart',
              'lib/shared/widgets/app_bottom_sheet.dart',
            },
          },
          reason: id);
      for (final path in changed.cast<String>()) {
        expect(allStages.last['binding_maps'][id]['after'][path],
            sha256.convert(File(path).readAsBytesSync()).toString());
      }
      for (final order in [stages, stages.reversed.toList()]) {
        validateVisualSourceChain(id,
            stages.first['binding_maps'][id]['before'] as Map, after, order);
      }
    }
  });

  test('startup deep links preserve retained oracle behavior', () {
    final stages = orderedVisualStages(readVisualStages());
    final stage = stages.singleWhere((s) => s['task'] == startupDeepLinksTask);
    final prior = stages[stages.indexOf(stage) - 1];
    expect(stage['task'], startupDeepLinksTask);
    expect(prior['task'], overlayHitTargetsTask);
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    for (final entry in (stage['binding_maps'] as Map).entries) {
      final before = entry.value['before'] as Map;
      final after = entry.value['after'] as Map;
      expect(before, prior['binding_maps'][entry.key]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      expect(
          before.keys.where((path) => before[path] != after[path]).toSet(),
          {
            'lib/core/services/rendering/palette/palette_service.dart',
            if (entry.key == 'physical-events')
              'lib/core/services/platform/deep_link_service.dart',
            if (before.containsKey(
                'test/migration/support/provenance_transition.dart'))
              'test/migration/support/provenance_transition.dart',
            if (before.containsKey(
                'test/migration/support/visual_presentation_evolution.dart'))
              'test/migration/support/visual_presentation_evolution.dart',
          },
          reason: entry.key as String);
      const historicalHelpers = {
        'test/migration/support/provenance_transition.dart':
            'c61dc40134e09adfb37ebb3b9482b1675c39e73d674e9514a42e19dcfd580cc0',
        'test/migration/support/visual_presentation_evolution.dart':
            'f4d5a4c6f39be2e6d7ad3374095958318c1da62b6af658df4107b985b8b930a7',
      };
      for (final path
          in before.keys.cast<String>().where((p) => before[p] != after[p])) {
        final current = sha256.convert(File(path).readAsBytesSync()).toString();
        expect(after[path], historicalHelpers[path] ?? current);
        expect(stages.last['binding_maps'][entry.key]['after'][path], current);
      }
    }
  });

  test('CPU parameter equality only transitions bound renderer and validators',
      () {
    const renderer = 'lib/features/renderer/cpu/cpu_fractal_renderer.dart';
    final stages = orderedVisualStages(readVisualStages());
    final stage = stages.singleWhere((s) => s['task'] == cpuRenderParamsTask);
    final prior = stages[stages.indexOf(stage) - 1];
    expect(stage['task'], cpuRenderParamsTask);
    expect(prior['task'], startupDeepLinksTask);
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    for (final entry in (stage['binding_maps'] as Map).entries) {
      final before = entry.value['before'] as Map;
      final after = entry.value['after'] as Map;
      expect(before, prior['binding_maps'][entry.key]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      final changed =
          before.keys.cast<String>().where((p) => before[p] != after[p]);
      expect(changed.toSet(), {
        if (entry.key == 'reference' || entry.key == 'physical-events')
          renderer,
        for (final helper in [
          'test/migration/support/provenance_transition.dart',
          'test/migration/support/visual_presentation_evolution.dart',
        ])
          if (before.containsKey(helper)) helper,
      });
      const historicalHelpers = {
        'test/migration/support/provenance_transition.dart':
            '162266b91a9510be045ed07390120b0ac8500e4f9acc550b1bab2ae8bef723ca',
        'test/migration/support/visual_presentation_evolution.dart':
            '01bfe4c6ade6d02176cf40538fd96d78444610a5e4a2d6c31a1db1fe3a2659ff',
      };
      for (final path in changed) {
        final current = sha256.convert(File(path).readAsBytesSync()).toString();
        expect(after[path], historicalHelpers[path] ?? current);
        expect(stages.last['binding_maps'][entry.key]['after'][path], current);
      }
    }
  });

  test('state-machine fixes only transition their bound sources and validators',
      () {
    const sources = {
      'lib/core/controllers/fractal_controller.dart',
      'lib/features/looper/looper_controller.dart',
      'lib/features/renderer/widgets/renderer/fractal_renderer.dart',
      'lib/features/renderer/widgets/renderer/input/gesture_handler.dart',
      'lib/features/viewer/diagnostics/gpu_health_probe.dart',
      'lib/features/viewer/diagnostics/viewer_gpu_health.dart',
      'lib/features/viewer/fractal_viewer_screen.dart',
      'test/migration/support/provenance_transition.dart',
      'test/migration/support/visual_presentation_evolution.dart',
    };
    final stages = orderedVisualStages(readVisualStages());
    final stage = stages.singleWhere((s) => s['task'] == stateMachineFixesTask);
    final prior = stages[stages.indexOf(stage) - 1];
    expect(stage['task'], stateMachineFixesTask);
    expect(prior['task'], cpuRenderParamsTask);
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    for (final entry in (stage['binding_maps'] as Map).entries) {
      final before = entry.value['before'] as Map;
      final after = entry.value['after'] as Map;
      expect(before, prior['binding_maps'][entry.key]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      final changed =
          before.keys.cast<String>().where((p) => before[p] != after[p]);
      expect(
          changed.toSet(),
          {
            for (final path in sources)
              if (before.containsKey(path)) path
          },
          reason: entry.key as String);
      const historicalSources = {
        'lib/features/viewer/fractal_viewer_screen.dart':
            '130d18a56639d9e1f65eb25a6cbdf5593ee4df8126a4df0b6992f3aadb6f1242',
        'lib/core/controllers/fractal_controller.dart':
            '8bf7f233db1606f779ba59231c4026c46f12e446b734e5c5373f45a400561f1d',
        'test/migration/support/provenance_transition.dart':
            'd56b206921c86e52216b004e0bf3fc0b46b02837701ec43895e94480da49e7ad',
        'test/migration/support/visual_presentation_evolution.dart':
            'cbc3e4fd39539c7bba3efc6d6e9819c499ba5735bd65ce44393f26996b0cc070',
      };
      for (final path in changed) {
        final current = sha256.convert(File(path).readAsBytesSync()).toString();
        expect(after[path], historicalSources[path] ?? current);
        expect(stages.last['binding_maps'][entry.key]['after'][path], current);
      }
    }
  });

  test('catalog addition support is a source-only maintenance successor', () {
    const helpers = {
      'test/migration/support/provenance_transition.dart',
      'test/migration/support/visual_presentation_evolution.dart',
    };
    final stages = orderedVisualStages(readVisualStages());
    final stage =
        stages.singleWhere((s) => s['task'] == catalogAdditionSupportTask);
    final prior = stages[stages.indexOf(stage) - 1];
    expect(stage['task'], catalogAdditionSupportTask);
    expect(prior['task'], stateMachineFixesTask);
    expect(stage['base_revision'], 'e1e47079b3473c6bf2f1e46871cd75b2123aa230');
    expect(stage['semantic_deltas'], isEmpty);
    expect(stage['compiled_artifacts'], isEmpty);
    for (final entry in (stage['binding_maps'] as Map).entries) {
      final before = entry.value['before'] as Map;
      final after = entry.value['after'] as Map;
      expect(before, prior['binding_maps'][entry.key]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      final changed = before.keys.where((p) => before[p] != after[p]).toSet();
      expect(changed, helpers.where(before.containsKey).toSet());
      const historicalHelpers = {
        'test/migration/support/provenance_transition.dart':
            '79290c052b7d70d1d868c2a351da09c69ca40c09849cc05b21dc12368eec4f31',
        'test/migration/support/visual_presentation_evolution.dart':
            'e2904e5bd09d137f72d331c71dd24fcacf17922f0c8beb10ac9d944ebfe44d28',
      };
      for (final path in changed.cast<String>()) {
        final current = sha256.convert(File(path).readAsBytesSync()).toString();
        expect(after[path], historicalHelpers[path]);
        expect(stages.last['binding_maps'][entry.key]['after'][path], current);
      }
    }
  });

  test('changed pilot default/schema is not an unchanged historical baseline',
      () {
    final inventory = buildBaselineInventory();
    for (final name in ['presets', 'parameters']) {
      final bytes = File('migration/baseline/$name.json').readAsStringSync();
      verifyBoundDocument(name, bytes, inventory[name]!);
      final changed = copy(inventory[name]!);
      final i = indexOf(changed, 'mandelbrot');
      final record = changed['payload']['records'][i];
      if (name == 'presets') {
        record['default']['params']['colorScheme'] = 63;
      } else {
        (record['parameters'] as List)
            .cast<Map>()
            .singleWhere((p) => p['id'] == 'colorScheme')['default'] = 63;
      }
      expect(() => verifyBoundDocument(name, bytes, changed), throwsStateError);
      expect(() => verifyBoundDocument(name, '$bytes ', inventory[name]!),
          throwsStateError,
          reason: 'original bytes cannot be repinned');
    }
  });

  test('explicit pilot delta preserves all other complete records', () {
    final old = retained('presets');
    final i = indexOf(old, 'mandelbrot');
    final stage = stageFor(visualDefaultsTask);
    stage['semantic_deltas']['presets'] = [
      {
        'path': '/payload/records/$i/default/view/zoom',
        'before': old['payload']['records'][i]['default']['view']['zoom'],
        'after': 7.0,
      }
    ];
    seal(stage);
    final expected = copy(old);
    expected['payload']['records'][i]['default']['view']['zoom'] = 7.0;
    expect(evolveVisualDocument('presets', old, [stage]), expected);
    expect(evolveVisualDocument('parameters', retained('parameters'), [stage]),
        retained('parameters'));
    for (final path in [
      '/payload/records/$i/default/params/iterations',
      '/payload/records/$i/default/id',
      '/payload/records/$i/built_in',
    ]) {
      final changed = copy(stage);
      changed['semantic_deltas']['presets'][0]['path'] = path;
      seal(changed);
      expect(() => evolveVisualDocument('presets', old, [changed]),
          throwsStateError,
          reason: path);
    }
    final stale = copy(stage);
    stale['semantic_deltas']['presets'][0]['before'] = -1;
    seal(stale);
    expect(
        () => evolveVisualDocument('presets', old, [stale]), throwsStateError);
  });

  test(
      'candidate source policies reject stale, unknown, removed and gapped maps',
      () {
    final stage = stageFor(visualProofTask);
    final maps = stage['binding_maps']['presets'] as Map;
    validateVisualSourceChain(
        'presets', maps['before'] as Map, maps['after'] as Map, [stage]);
    for (final mutation in [
      'unknown',
      'path',
      'remove',
      'gap',
      'identity',
      'blank'
    ]) {
      final bad = copy(stage);
      final record = bad['binding_maps']['presets'] as Map;
      switch (mutation) {
        case 'unknown':
          bad['task'] = 'FUTURE';
        case 'path':
          record['after']['unlisted.dart'] = 'a' * 64;
        case 'remove':
          (record['after'] as Map).remove('pubspec.lock');
        case 'gap':
          record['before']['pubspec.lock'] = 'b' * 64;
        case 'blank':
          record['after'] = copy(record['before'] as Map);
      }
      seal(bad);
      if (mutation == 'identity') bad['candidate_identity'] = 'b' * 64;
      expect(
          () => validateVisualSourceChain(
              'presets', maps['before'] as Map, maps['after'] as Map, [bad]),
          throwsStateError,
          reason: mutation);
    }
    expect(
        () => validateVisualSourceChain(
            'presets', maps['before'] as Map, maps['before'] as Map, [stage]),
        throwsStateError,
        reason: 'stale current source');
    expect(
        () => validateVisualSourceChain('presets', maps['before'] as Map,
            maps['after'] as Map, [stage, stage]),
        throwsStateError);
  });

  test('candidate ordering uses full bundles, never independent map orders',
      () {
    final proof = stageFor(visualProofTask);
    final defaults = stageFor(visualDefaultsTask);
    for (final name in (defaults['binding_maps'] as Map).keys) {
      final after = proof['binding_maps'][name]['after'] as Map;
      defaults['binding_maps'][name] = {
        'before': copy(after),
        'after': copy(after),
      };
    }
    const path =
        'lib/core/modules/builders/escape_time_catalog/families/core_escape_time_family.dart';
    defaults['binding_maps']['parameters']['after'][path] = 'b' * 64;
    seal(defaults);
    expect(orderedVisualStages([defaults, proof]), [proof, defaults]);

    // Presets order proof -> defaults, but parameters order defaults -> proof.
    // Each map alone looked valid; there is no adjacent complete bundle.
    final crossed = copy(defaults);
    final parameters = crossed['binding_maps']['parameters'] as Map;
    final original = parameters['before'][path];
    parameters['before'][path] = parameters['after'][path];
    parameters['after'][path] = original;
    seal(crossed);
    validateVisualStage(crossed);
    for (final name in ['presets', 'parameters']) {
      final initial = name == 'parameters'
          ? crossed['binding_maps'][name]['before'] as Map
          : proof['binding_maps'][name]['before'] as Map;
      final terminal = name == 'parameters'
          ? proof['binding_maps'][name]['after'] as Map
          : crossed['binding_maps'][name]['after'] as Map;
      expect(
          () => validateVisualSourceChain(
              name, initial, terminal, [proof, crossed]),
          throwsStateError);
    }
    expect(
        () => evolveVisualDocument(
            'presets', retained('presets'), [proof, crossed]),
        throwsStateError);
  });

  test('only exact optional synthetic fixture may extend shader inventory', () {
    final old = retained('shader-contracts');
    final stage = stageFor(visualSurfaceTask);
    final maps = stage['binding_maps']['shader-contracts'] as Map;
    maps['after'][visualFixture] = 'a' * 64;
    maps['after']['pubspec.yaml'] = 'b' * 64;
    stage['semantic_deltas']['shader-contracts'] = [
      {
        'path': '/payload/records/-',
        'before': null,
        'after': visualFixtureContract(),
      }
    ];
    seal(stage);
    final result = evolveVisualDocument('shader-contracts', old, [stage]);
    expect((result['payload']['records'] as List).length,
        (old['payload']['records'] as List).length + 1);
    expect(
        (result['payload']['records'] as List)
            .cast<Map>()
            .where((r) => r['asset'] != visualFixture)
            .toList(),
        old['payload']['records']);
    for (final mutation in [
      'extra',
      'uniform',
      'module',
      'unbound',
      'duplicate'
    ]) {
      final bad = copy(stage);
      final delta = bad['semantic_deltas']['shader-contracts'][0] as Map;
      switch (mutation) {
        case 'extra':
          delta['after']['asset'] = 'test/shaders/extra.frag';
          bad['binding_maps']['shader-contracts']['after']
              ['test/shaders/extra.frag'] = 'a' * 64;
        case 'uniform':
          delta['after']['float_slots'][1]['slot'] = 3;
        case 'module':
          delta['after']['module_ids'] = ['mandelbulb'];
        case 'unbound':
          (bad['binding_maps']['shader-contracts']['after'] as Map)
              .remove(visualFixture);
        case 'duplicate':
          bad['semantic_deltas']['shader-contracts'].add(copy(delta));
      }
      seal(bad);
      expect(() => evolveVisualDocument('shader-contracts', old, [bad]),
          throwsStateError,
          reason: mutation);
    }
  });

  test(
      'missing plugin or skipped shader never reconciles as successful capture',
      () {
    validateVisualCaptureCounts(
        selected: 40, rendered: 40, failed: 0, skipped: 0);
    for (final counts in [
      [39, 1, 0],
      [39, 0, 1],
      [39, 0, 0],
      [0, 0, 40]
    ]) {
      expect(
          () => validateVisualCaptureCounts(
              selected: 40,
              rendered: counts[0],
              failed: counts[1],
              skipped: counts[2]),
          throwsA(isA<StateError>().having((e) => e.message, 'repair',
              contains('restore shader/plugin/export support and rerun'))));
    }
  });
  test('only enumerated color fields may evolve, with legacy 3D defaults', () {
    final old = retained('parameters');
    for (final id in visualPilotIds) {
      final i = indexOf(old, id);
      final parameters = old['payload']['records'][i]['parameters'] as List;
      final j = parameters.indexWhere((p) => p['id'] == 'colorScheme');
      final parameter = parameters[j] as Map;
      final surface = ['mandelbulb', 'mandelbox'].contains(id);
      final stage = stageFor(surface ? visualSurfaceTask : visualDefaultsTask);
      final max = id == 'mandelbulb' ? 4 : 8;
      stage['semantic_deltas']['parameters'] = surface
          ? [
              {
                'path': '/payload/records/$i/parameters/$j/max',
                'before': parameter['max'],
                'after': max
              },
              {
                'path': '/payload/records/$i/parameters/$j/options',
                'before': parameter['options'],
                'after': [
                  ...parameter['options'] as List,
                  {'value': max, 'label_en': 'Sculptural'},
                ]
              },
            ]
          : [
              {
                'path': '/payload/records/$i/parameters/$j/default',
                'before': parameter['default'],
                'after': 7
              },
            ];
      seal(stage);
      final result = evolveVisualDocument('parameters', old, [stage]);
      final evolved = result['payload']['records'][i]['parameters'][j] as Map;
      expect(evolved['default'], surface ? parameter['default'] : 7);
      final bad = copy(stage);
      bad['semantic_deltas']['parameters'] = [
        {
          'path':
              '/payload/records/$i/parameters/$j/${surface ? 'default' : 'max'}',
          'before': surface ? parameter['default'] : parameter['max'],
          'after': 99
        },
      ];
      seal(bad);
      expect(() => evolveVisualDocument('parameters', old, [bad]),
          throwsStateError);
    }
    final stage = stageFor(visualSurfaceTask);
    final contracts = retained('shader-contracts');
    stage['semantic_deltas']['shader-contracts'] = [
      {'path': '/payload/records/0/float_slot_count', 'before': 0, 'after': 1},
    ];
    seal(stage);
    expect(() => evolveVisualDocument('shader-contracts', contracts, [stage]),
        throwsStateError,
        reason: 'Production uniform declarations stay exact');
  });
  test('optional fixture registration permits exactly the named single entry',
      () {
    const before = 'name: app\nflutter:\n  shaders:\n    - shaders/old.frag\n';
    final after = '$before    - $visualFixture\n';
    validateVisualFixtureRegistration(before, after);
    for (final bad in [
      '$after    - test/shaders/unlisted.frag\n',
      '$after    - $visualFixture\n',
      after.replaceFirst('name: app', 'name: different'),
      after.replaceFirst('    - shaders/old.frag\n', ''),
      before,
    ]) {
      expect(() => validateVisualFixtureRegistration(before, bad),
          throwsStateError);
    }
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    final declarations = shaderDeclarations(
        visualFixture,
        (path) => path == visualFixture
            ? '#include <flutter/runtime_effect.glsl>\nuniform vec2 uResolution;\nuniform float uCase;'
            : File('$sdk/engine/src/flutter/impeller/compiler/shader_lib/$path')
                .readAsStringSync());
    final contract = visualFixtureContract();
    for (final key in declarations.keys) {
      expect(contract[key], declarations[key], reason: key);
    }
  });
}
