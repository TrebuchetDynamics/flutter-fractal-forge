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

  test('viewer export successor binds only the exact maintenance source delta',
      () {
    final stages = orderedVisualStages(readVisualStages());
    final stage = stages.last;
    final prior = stages[stages.length - 2];
    expect(stage['task'], viewerExportStateTask);
    expect(prior['task'], shaderCacheRecoveryTask);
    expect(stage['base_revision'], '92a36981966eddc4b48a6d7c6820bf39e7e8ac25');
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
            if (helperMaps.contains(id)) ...helpers,
          },
          reason: id);
      for (final path in changed.cast<String>()) {
        expect(after[path],
            sha256.convert(File(path).readAsBytesSync()).toString(),
            reason: '$id: $path');
      }
      for (final order in [stages, stages.reversed.toList()]) {
        validateVisualSourceChain(id,
            stages.first['binding_maps'][id]['before'] as Map, after, order);
      }
    }
  });

  test(
      'viewer export policy rejects self-consistent broadened and stale claims',
      () {
    final stages = orderedVisualStages(readVisualStages());
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
  });
}
