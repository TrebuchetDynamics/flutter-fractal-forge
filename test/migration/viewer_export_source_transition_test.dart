import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  const productionPaths = {
    'lib/features/viewer/diagnostics/gpu_health_probe.dart',
    'lib/features/viewer/diagnostics/viewer_gpu_health.dart',
    'lib/features/viewer/export/viewer_export_actions.dart',
    'lib/features/viewer/fractal_viewer_screen.dart',
    'lib/features/viewer/navigation/viewer_interactions.dart',
  };
  const helpers = {
    'test/migration/support/provenance_transition.dart',
    'test/migration/support/visual_presentation_evolution.dart',
  };
  const helperMaps = {
    'param-interpolation',
    'physical-events',
    'precision-replay',
    'randomization',
    'reference',
    'state-replay',
  };

  Map archived() => validateVisualArchive({
        'viewer-export-state.json': File(
                '$visualStageRoot/archived-candidates/viewer-export-state.json')
            .readAsBytesSync(),
      });

  test('archived viewer retains exact historical policy and changed hashes',
      () {
    final stage = archived();
    final stages = readVisualStages();
    final recovery =
        stages.singleWhere((s) => s['task'] == shaderCacheRecoveryTask);
    const hashes = {
      'test/migration/support/provenance_transition.dart':
          '1c896cb2cf60902bbbfb28dc37570079373ad3754ef0361a0f51a46e975507a9',
      'test/migration/support/visual_presentation_evolution.dart':
          '3a2d56d1bbd8589bfa3edcfac1e8279095e51482da2a244ba98298e224dcf1a7',
      'lib/features/viewer/diagnostics/gpu_health_probe.dart':
          'c25402a3109a98d629323c1020f6a724946d9548607265093411dfa7ce61c3cf',
      'lib/features/viewer/diagnostics/viewer_gpu_health.dart':
          '27d1f1964d5c8f8064c92ff3fd06f7a208828edd38465199edd4e17262af43f7',
      'lib/features/viewer/export/viewer_export_actions.dart':
          'ad93db9fb534c68c62c42556f17acbd741c01c384b5e05a06031d8f429ca2dd0',
      'lib/features/viewer/fractal_viewer_screen.dart':
          '2e72fbf8e7d0e9ead7ae10936f00e2b4dbe4f72c6afe9a8fe76c336724d5674b',
      'lib/features/viewer/navigation/viewer_interactions.dart':
          '0136f541e62468c5e8cb54a54764623803ad670ed82f2ddc3676884228982d0c',
    };
    expect(stage['base_revision'], '92a36981966eddc4b48a6d7c6820bf39e7e8ac25');
    final historical = [
      stages.singleWhere((s) => s['task'] == visualProofTask),
      recovery,
      stage,
    ];
    for (final id in (stage['binding_maps'] as Map).keys.cast<String>()) {
      final before = stage['binding_maps'][id]['before'] as Map;
      final after = stage['binding_maps'][id]['after'] as Map;
      expect(before, recovery['binding_maps'][id]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      final changed = before.keys.where((p) => before[p] != after[p]).toSet();
      expect(changed, {
        if (id == 'physical-events') ...productionPaths,
        if (helperMaps.contains(id)) ...helpers,
      });
      for (final path in changed) {
        expect(after[path], hashes[path], reason: '$id: $path');
      }
      for (final order in [
        historical,
        historical.reversed.toList(),
        [stage, historical.first, recovery]
      ]) {
        validateVisualSourceChain(
            id,
            historical.first['binding_maps'][id]['before'] as Map,
            after,
            order);
      }
    }
    for (final order in [
      [...stages, stage],
      [stage, ...stages.reversed]
    ]) {
      expect(() => orderedVisualStages(order), throwsStateError);
    }
  });

  test('mandatory archive rejects missing altered extra and nested entries',
      () {
    final bytes =
        File('$visualStageRoot/archived-candidates/viewer-export-state.json')
            .readAsBytesSync();
    for (final entries in <Map<String, List<int>>>[
      {},
      {
        'viewer-export-state.json': [...bytes, 10]
      },
      {'viewer-export-state.json': bytes, 'unknown.json': bytes},
      {'nested/viewer-export-state.json': bytes},
      {'viewer-export-state.json': bytes, 'nested/unknown.json': bytes},
    ]) {
      expect(() => validateVisualArchive(entries), throwsStateError);
    }
  });

  test('viewer export successor binds only the exact maintenance source delta',
      () {
    final stages = orderedVisualStages(readVisualStages())
        .takeWhile((s) => s['task'] != phoneSliderTask)
        .toList();
    final stage = stages.last;
    final prior = stages[stages.length - 2];
    expect(stage['task'], viewerExportIntegrationTask);
    expect(prior['task'], presetBatchExportTask);
    expect(stage['base_revision'], '968b30958bce5755166526658d55f755bd7dbd62');
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
            if (id == 'physical-events') ...productionPaths,
            if (id == 'physical-events')
              'lib/features/viewer/export/viewer_export_session.dart',
            if (helperMaps.contains(id)) ...helpers,
          },
          reason: id);
      for (final path in changed.cast<String>()) {
        const historicalHelpers = {
          'test/migration/support/provenance_transition.dart':
              '4ea924e305135a5340a4fbfa521a6dba8fee10fc48693ff476b8540936031528',
          'test/migration/support/visual_presentation_evolution.dart':
              'ca25ca71ae01c978e1b4e47c866c3e38d2dc3a362107d640a408561819287766',
        };
        expect(
            after[path],
            historicalHelpers[path] ??
                sha256.convert(File(path).readAsBytesSync()).toString(),
            reason: '$id: $path');
      }
      for (final order in [
        stages,
        stages.reversed.toList(),
        [stages[2], stages[0], stages[3], stages[1]]
      ]) {
        validateVisualSourceChain(id,
            stages.first['binding_maps'][id]['before'] as Map, after, order);
      }
    }
  });

  test(
      'viewer export policy rejects self-consistent broadened and stale claims',
      () {
    final stages = orderedVisualStages(readVisualStages())
        .takeWhile((s) => s['task'] != phoneSliderTask)
        .toList();
    final stage = stages.last;
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
      'missing',
      'duplicate',
      'missing-map',
      'extra-map',
    ]) {
      final bad = copy(stage);
      final record = bad['binding_maps']['physical-events'] as Map;
      switch (mutation) {
        case 'semantic':
          bad['semantic_deltas']['presets'] = [];
        case 'compiled':
          bad['compiled_artifacts'] = [{}];
        case 'unrelated':
          record['after']['pubspec.lock'] = 'c' * 64;
        case 'add-allowed':
          bad['binding_maps']['presets']['after'][productionPaths.first] =
              'c' * 64;
        case 'remove':
          (record['after'] as Map).remove(productionPaths.first);
        case 'unknown':
          bad['task'] = 'VIEWER-EXPORT-STATE-02';
        case 'gap':
          record['before'][productionPaths.first] = 'c' * 64;
        case 'stale':
          record['after'][productionPaths.first] = 'c' * 64;
        case 'missing-map':
          (bad['binding_maps'] as Map).remove('presets');
        case 'extra-map':
          bad['binding_maps']['unknown'] = copy(record);
      }
      seal(bad);
      if (mutation == 'identity') bad['candidate_identity'] = 'c' * 64;
      final selected = [
        ...stages.take(stages.length - 1),
        if (mutation != 'missing') bad,
        if (mutation == 'duplicate') bad,
      ];
      expect(() {
        for (final id in (stage['binding_maps'] as Map).keys.cast<String>()) {
          validateVisualSourceChain(
              id,
              stages.first['binding_maps'][id]['before'] as Map,
              stage['binding_maps'][id]['after'] as Map,
              selected);
        }
      }, throwsStateError, reason: mutation);
    }
    for (final omitted in stages) {
      final selected = stages.where((s) => s != omitted).toList();
      for (final id in (stage['binding_maps'] as Map).keys.cast<String>()) {
        // Inventory identities alone cannot detect an omitted source-only
        // stage; validate every complete bundle against physical-events too.
        expect(() {
          validateVisualSourceChain(
              id,
              stages.first['binding_maps'][id]['before'] as Map,
              stage['binding_maps'][id]['after'] as Map,
              selected);
          validateVisualSourceChain(
              'physical-events',
              stages.first['binding_maps']['physical-events']['before'] as Map,
              stage['binding_maps']['physical-events']['after'] as Map,
              selected);
        }, throwsStateError, reason: '$id: missing ${omitted['task']}');
      }
    }
  });
}
