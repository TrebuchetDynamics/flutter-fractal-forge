import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';

import 'support/provenance_transition.dart';
import 'support/visual_presentation_evolution.dart';

Map _copy(Map value) => jsonDecode(jsonEncode(value)) as Map;

void _seal(Map stage) {
  final maps = stage['binding_maps'] as Map;
  for (final record in maps.values.cast<Map>()) {
    final before = record['before'] as Map, after = record['after'] as Map;
    record['changed'] = before.keys
        .where((k) => after.containsKey(k) && before[k] != after[k])
        .toList()
      ..sort();
    record['added'] =
        after.keys.toSet().difference(before.keys.toSet()).toList()..sort();
    record['removed'] =
        before.keys.toSet().difference(after.keys.toSet()).toList()..sort();
  }
  stage['candidate_identity'] = sha256
      .convert(utf8.encode(canonicalJson({
        for (final id in maps.keys) id: maps[id]['after'],
      })))
      .toString();
}

void main() {
  test(
      'baseline-only stage composes unchanged maps without widening task policy',
      () {
    final stages = readProvenanceStages();
    final baseline =
        stages.singleWhere((s) => s['task'] == 'ACAD-015-BASELINE');
    final task = stages.singleWhere((s) => s['task'] == 'ACAD-015');
    for (final id in (baseline['binding_maps'] as Map).keys.cast<String>()) {
      final before = baseline['binding_maps'][id]['before'] as Map;
      final after = task['binding_maps'][id]['after'] as Map;
      verifySourceStages(id, before, after, stages: [task, baseline]);
    }

    final changed = jsonDecode(jsonEncode(baseline)) as Map;
    changed['allowed_paths'] = task['allowed_paths'];
    expect(() => validateProvenanceStage(changed), throwsStateError);
    // The reconciliation cannot turn a missing stage into implicit acceptance.
    expect(
      () => verifySourceStages(
        'physical-events',
        baseline['binding_maps']['physical-events']['before'] as Map,
        task['binding_maps']['physical-events']['after'] as Map,
        stages: [task],
      ),
      throwsStateError,
    );
  });

  test('preset keyboard stage is adjacent, complete and narrowly authorized',
      () {
    final stages = readProvenanceStages();
    final keyboard =
        stages.singleWhere((s) => s['task'] == 'MAINT-PRESET-KEYBOARD-01');
    final terminal = stages.singleWhere((s) => s['task'] == 'ACAD-015');
    expect(stages.map((s) => s['task']).toSet(), {
      'RUST-CORE-BOOTSTRAP',
      'MAINT-A11Y-STATUS-COPY-01',
      'ACAD-015-BASELINE',
      'ACAD-015',
      'MAINT-PRESET-KEYBOARD-01',
      'HISTORY-COMMIT-REPLAY-01',
    });
    expect(
        keyboard['base_revision'], '059cc9783fe26bd65266c0f8c5cb3b3a244a607a');
    expect(keyboard['allowed_paths'], [
      'lib/features/presets/preset_sheet.dart',
      'test/migration/support/provenance_transition.dart',
    ]);
    final maps = keyboard['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final id in maps.keys.cast<String>()) {
      final record = maps[id] as Map;
      expect(record['before'], terminal['binding_maps'][id]['after']);
      expect(record['added'], isEmpty);
      expect(record['removed'], isEmpty);
      final expectedChanged = [
        if (id == 'physical-events') 'lib/features/presets/preset_sheet.dart',
        if ([
          'param-interpolation',
          'physical-events',
          'precision-replay',
          'randomization',
          'reference',
          'state-replay'
        ].contains(id))
          'test/migration/support/provenance_transition.dart',
      ];
      expect(record['changed'], expectedChanged, reason: id);
      // Keyboard bindings remain historical; candidates bind current helpers.
      for (final path in expectedChanged) {
        if (path == 'test/migration/support/provenance_transition.dart') {
          expect(record['after'][path],
              '27778ec2aae6a2efd9db99e851a4e6d7cd7ddcbcaaf63e0483370de3fd839659');
        } else {
          expect(record['after'][path],
              'e6ceeabf474cfd59e1eca0144da4dffbed4fca970486d8a793e62634dc72e309');
        }
      }
      verifySourceStages(id, stages.first['binding_maps'][id]['before'] as Map,
          record['after'] as Map,
          stages: stages
              .where((s) => s['task'] != 'HISTORY-COMMIT-REPLAY-01')
              .toList()
              .reversed
              .toList());
    }
  });

  test('history stage composes eleven-map bundles independent of input order',
      () {
    final stages = readProvenanceStages();
    final history =
        stages.singleWhere((s) => s['task'] == 'HISTORY-COMMIT-REPLAY-01');
    final keyboard =
        stages.singleWhere((s) => s['task'] == 'MAINT-PRESET-KEYBOARD-01');
    expect(
        history['base_revision'], '08f3040d990d5df04de6c3f3834ccf30e592235a');
    expect(history['change_reference'],
        'docs/tasks/source-bound-review-gates.md#history-commit-replay');
    const allowed = [
      'lib/features/history/history_provider.dart',
      'lib/features/history/history_replay.dart',
      'lib/features/viewer/fractal_viewer_screen.dart',
      'test/migration/support/provenance_transition.dart',
    ];
    expect(history['allowed_paths'], allowed);
    final maps = history['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final id in maps.keys.cast<String>()) {
      final record = maps[id] as Map;
      expect(record['before'], keyboard['binding_maps'][id]['after']);
      expect(record['added'], isEmpty);
      expect(record['removed'], isEmpty);
      final expectedChanged = [
        if (id == 'physical-events') ...allowed.take(3),
        if ([
          'param-interpolation',
          'physical-events',
          'precision-replay',
          'randomization',
          'reference',
          'state-replay'
        ].contains(id))
          allowed.last,
      ];
      expect(record['changed'], expectedChanged, reason: id);
      for (final path in expectedChanged) {
        if (path == 'test/migration/support/provenance_transition.dart') {
          expect(record['after'][path],
              '07cd6e577a0866f1200fce76a890798686c8d576b9d9df556393a5b20d3137b5');
          expect(
              orderedVisualStages(readVisualStages()).last['binding_maps'][id]
                  ['after'][path],
              sha256.convert(File(path).readAsBytesSync()).toString());
        } else if (path == 'lib/features/viewer/fractal_viewer_screen.dart') {
          expect(record['after'][path],
              'da8c6a54c4e918cd908c93b06cb246d75e3bce79c35b57e3252ea1707b587f03');
          expect(
              orderedVisualStages(readVisualStages()).last['binding_maps'][id]
                  ['after'][path],
              sha256.convert(File(path).readAsBytesSync()).toString());
        } else {
          expect(
              record['after'][path],
              path == 'lib/features/viewer/fractal_viewer_screen.dart'
                  ? 'da8c6a54c4e918cd908c93b06cb246d75e3bce79c35b57e3252ea1707b587f03'
                  : sha256.convert(File(path).readAsBytesSync()).toString());
        }
      }
      for (final order in [
        stages.reversed.toList(),
        [stages[3], stages[5], stages[1], stages[4], stages[0], stages[2]],
        [history, keyboard],
      ]) {
        final before = order.length == 2
            ? keyboard['binding_maps'][id]['before'] as Map
            : stages.first['binding_maps'][id]['before'] as Map;
        verifySourceStages(id, before, record['after'] as Map, stages: order);
      }
    }
  });

  test('shader recovery follows visual proof in every complete-map input order',
      () {
    final historical = readProvenanceStages();
    final candidates = readVisualStages();
    expect(candidates.map((s) => s['task']).toSet(), {
      visualProofTask,
      shaderCacheRecoveryTask,
      presetBatchExportTask,
      viewerExportIntegrationTask,
      phoneSliderTask,
      directEditControlsTask,
      overlayHitTargetsTask,
      startupDeepLinksTask,
      cpuRenderParamsTask,
      stateMachineFixesTask,
      catalogAdditionSupportTask,
      recamanArcsTask,
      zetaCriticalStripTask,
      juliaUniformOrderTask,
      escapeTimeUniformDefaultsTask,
      perturbationOrbitCacheKeyTask,
      historyReplayModuleIdTask,
      visualSurfaceTask,
      androidGallerySaveTask,
      visualDefaultsTask,
      mandelbrotDf2Task,
      exportCaptureSizeLimitTask,
      diagnosticShareUtf8Task,
      contactSheetAspectTask,
      wallpaperStyleWorkerTask,
      unusedHelpersTask,
    });
    final proof = candidates.singleWhere((s) => s['task'] == visualProofTask);
    final recovery =
        candidates.singleWhere((s) => s['task'] == shaderCacheRecoveryTask);
    final viewer =
        candidates.singleWhere((s) => s['task'] == viewerExportIntegrationTask);
    final phone = candidates.singleWhere((s) => s['task'] == phoneSliderTask);
    final directEdit =
        candidates.singleWhere((s) => s['task'] == directEditControlsTask);
    final overlay =
        candidates.singleWhere((s) => s['task'] == overlayHitTargetsTask);
    final startup =
        candidates.singleWhere((s) => s['task'] == startupDeepLinksTask);
    final cpu = candidates.singleWhere((s) => s['task'] == cpuRenderParamsTask);
    final stateMachine =
        candidates.singleWhere((s) => s['task'] == stateMachineFixesTask);
    final catalogSupport =
        candidates.singleWhere((s) => s['task'] == catalogAdditionSupportTask);
    final recaman = candidates.singleWhere((s) => s['task'] == recamanArcsTask);
    final zeta =
        candidates.singleWhere((s) => s['task'] == zetaCriticalStripTask);
    final julia =
        candidates.singleWhere((s) => s['task'] == juliaUniformOrderTask);
    final escapeTimeDefaults = candidates
        .singleWhere((s) => s['task'] == escapeTimeUniformDefaultsTask);
    final orbitCacheKey = candidates
        .singleWhere((s) => s['task'] == perturbationOrbitCacheKeyTask);
    expect(orbitCacheKey['semantic_deltas'], isEmpty);
    expect(orbitCacheKey['compiled_artifacts'], isEmpty);
    final historyReplay =
        candidates.singleWhere((s) => s['task'] == historyReplayModuleIdTask);
    expect(historyReplay['semantic_deltas'], isEmpty);
    expect(historyReplay['compiled_artifacts'], isEmpty);
    final surface =
        candidates.singleWhere((s) => s['task'] == visualSurfaceTask);
    final gallerySave =
        candidates.singleWhere((s) => s['task'] == androidGallerySaveTask);
    expect(gallerySave['semantic_deltas'], isEmpty);
    expect(gallerySave['compiled_artifacts'], isEmpty);
    final defaults =
        candidates.singleWhere((s) => s['task'] == visualDefaultsTask);
    final df2 = candidates.singleWhere((s) => s['task'] == mandelbrotDf2Task);
    final captureLimit =
        candidates.singleWhere((s) => s['task'] == exportCaptureSizeLimitTask);
    expect(captureLimit['semantic_deltas'], isEmpty);
    expect(captureLimit['compiled_artifacts'], isEmpty);
    final diagnosticShare =
        candidates.singleWhere((s) => s['task'] == diagnosticShareUtf8Task);
    expect(diagnosticShare['semantic_deltas'], isEmpty);
    expect(diagnosticShare['compiled_artifacts'], isEmpty);
    final contactSheet =
        candidates.singleWhere((s) => s['task'] == contactSheetAspectTask);
    expect(contactSheet['semantic_deltas'], isEmpty);
    expect(contactSheet['compiled_artifacts'], isEmpty);
    final wallpaperStyleWorker =
        candidates.singleWhere((s) => s['task'] == wallpaperStyleWorkerTask);
    expect(wallpaperStyleWorker['semantic_deltas'], isEmpty);
    expect(wallpaperStyleWorker['compiled_artifacts'], isEmpty);
    final unusedHelpers =
        candidates.singleWhere((s) => s['task'] == unusedHelpersTask);
    expect(unusedHelpers['semantic_deltas'], isEmpty);
    expect(unusedHelpers['compiled_artifacts'], isEmpty);
    expect(
        recovery['base_revision'], '6031f27314ad6cbe58cca3cebf9e60d10af4aaf1');
    expect(recovery['semantic_deltas'], isEmpty);
    expect(recovery['compiled_artifacts'], isEmpty);
    const allowed = {
      'lib/features/renderer/widgets/renderer/shaders/shader_loader.dart',
      'test/migration/support/provenance_transition.dart',
      'test/migration/support/visual_presentation_evolution.dart',
    };
    final maps = recovery['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final order in [candidates, candidates.reversed.toList()]) {
      expect(orderedVisualStages(order), [
        proof,
        recovery,
        candidates.singleWhere((s) => s['task'] == presetBatchExportTask),
        viewer,
        phone,
        directEdit,
        overlay,
        startup,
        cpu,
        stateMachine,
        catalogSupport,
        recaman,
        zeta,
        julia,
        escapeTimeDefaults,
        orbitCacheKey,
        historyReplay,
        surface,
        gallerySave,
        defaults,
        df2,
        captureLimit,
        diagnosticShare,
        contactSheet,
        wallpaperStyleWorker,
        unusedHelpers,
      ]);
      for (final id in maps.keys.cast<String>()) {
        final record = maps[id] as Map;
        final before = record['before'] as Map;
        final after = record['after'] as Map;
        expect(before, proof['binding_maps'][id]['after'], reason: id);
        expect(after.keys.toSet(), before.keys.toSet(), reason: id);
        for (final path in after.keys.cast<String>()) {
          const historicalHelpers = {
            'test/migration/support/provenance_transition.dart':
                '2ca789e4a08ba67d41129b00ec7632d5c93c0489980079c6c9ad2d55dc6a3fca',
            'test/migration/support/visual_presentation_evolution.dart':
                'e9b0ec2a49982b7dcb5f7a92c55c2a00dd206a716d58cbf6cd8c58125171c914',
          };
          expect(
              after[path],
              historicalHelpers[path] ??
                  (allowed.contains(path)
                      ? sha256.convert(File(path).readAsBytesSync()).toString()
                      : before[path]),
              reason: '$id: $path');
        }
        verifySourceStages(
            id,
            historical.first['binding_maps'][id]['before'] as Map,
            unusedHelpers['binding_maps'][id]['after'] as Map,
            stages: [...order, ...historical.reversed]);
      }
    }
  });

  test('preset batch successor binds only the changed export sources', () {
    final candidates = readVisualStages();
    final ordered = orderedVisualStages(candidates);
    final batch =
        ordered.singleWhere((s) => s['task'] == presetBatchExportTask);
    final terminal = ordered.last;
    const historicalHashes = {
      'lib/core/services/export/batch_export_service.dart':
          '652900e79cc77a25e87fc72ed246ef7d7428f4ac46af5ad933afca4c8d453025',
      'lib/core/services/storage/preset_store.dart':
          'db6d68780c737a0261ee04f7e1317213211971b5051f018c6cafc00e19911847',
      'lib/features/export/batch_export_dialog.dart':
          'bcf21d99ec2f91b75bec42cf4d12da9adde18cb314d6844a278d54967f138198',
      'lib/features/presets/preset_sheet.dart':
          '07fb53afb571dbab8deaa55e8e7a8f49077c1fb3e14a4dcd5a8d9cb69964c56e',
      'lib/features/viewer/dialogs/viewer_dialogs.dart':
          '209a90e099a5eccda273064a463eb48e2c02f5c76887962157c6eac46b5cbc2a',
      'test/migration/support/provenance_transition.dart':
          'baf90f16755dcf1578cc32c835d0d96b32a8722e83f655b76bfddf06a34fdb11',
      'test/migration/support/visual_presentation_evolution.dart':
          '1c52828f4c8790d55ccfcec699ab54286558095c849e80b47884d42076eb3d06',
      'lib/features/viewer/fractal_viewer_screen.dart':
          '2fa7e006a864c607628994beb664c9422cbe1088822744c501c8293f80c47a12',
    };
    expect(batch['task'], presetBatchExportTask);
    expect(batch['base_revision'], '6d907b014a4abdaccfe4e6c3dfbc94d1bebf1723');
    expect(batch['semantic_deltas'], isEmpty);
    expect(batch['compiled_artifacts'], isEmpty);
    const allowed = {
      'lib/core/services/export/batch_export_service.dart',
      'lib/core/services/storage/preset_store.dart',
      'lib/features/export/batch_export_dialog.dart',
      'lib/features/presets/preset_sheet.dart',
      'lib/features/viewer/dialogs/viewer_dialogs.dart',
      'lib/features/viewer/fractal_viewer_screen.dart',
      'test/migration/support/provenance_transition.dart',
      'test/migration/support/visual_presentation_evolution.dart',
    };
    final maps = batch['binding_maps'] as Map;
    expect(maps.length, 11);
    for (final id in maps.keys.cast<String>()) {
      final before = maps[id]['before'] as Map;
      final after = maps[id]['after'] as Map;
      expect(before,
          ordered[ordered.indexOf(batch) - 1]['binding_maps'][id]['after']);
      expect(after.keys.toSet(), before.keys.toSet());
      for (final path in after.keys.cast<String>()) {
        expect(after[path],
            allowed.contains(path) ? historicalHashes[path] : before[path],
            reason: '$id: $path');
      }
      verifySourceStages(
          id,
          readProvenanceStages().first['binding_maps'][id]['before'] as Map,
          terminal['binding_maps'][id]['after'] as Map,
          stages: [...readProvenanceStages().reversed, ...candidates.reversed]);
    }
  });

  test('full-bundle branches no-ops gaps cycles and policy mutations reject',
      () {
    final stages = readProvenanceStages();
    final history =
        stages.singleWhere((s) => s['task'] == 'HISTORY-COMMIT-REPLAY-01');
    final keyboard =
        stages.singleWhere((s) => s['task'] == 'MAINT-PRESET-KEYBOARD-01');
    const id = 'physical-events';
    const hash =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final initial = stages.first['binding_maps'][id]['before'] as Map;
    final terminal = history['binding_maps'][id]['after'] as Map;
    for (final mutation in [
      'branch',
      'no-op',
      'gap',
      'policy',
      'anchor',
      'unlisted',
      'remove',
      'identity'
    ]) {
      final changed = _copy(history);
      final records = changed['binding_maps'] as Map;
      for (final name in records.keys) {
        final record = records[name] as Map;
        switch (mutation) {
          case 'branch':
            record['before'] =
                _copy(keyboard['binding_maps'][name]['before'] as Map);
            record['after'] = _copy(record['before'] as Map);
            if (record['after'].containsKey(
                'test/migration/support/provenance_transition.dart')) {
              record['after']
                  ['test/migration/support/provenance_transition.dart'] = hash;
            }
          case 'no-op':
            record['after'] = _copy(record['before'] as Map);
        }
      }
      final record = records[id] as Map;
      switch (mutation) {
        case 'gap':
          record['before']['lib/features/history/history_provider.dart'] = hash;
        case 'policy':
          changed['allowed_paths']
              .add('lib/core/controllers/fractal_controller.dart');
        case 'anchor':
          changed['retained_document_hashes']['modules'] = hash;
        case 'unlisted':
          record['after']['lib/core/controllers/fractal_controller.dart'] =
              hash;
        case 'remove':
          record['after'].remove('lib/features/history/history_replay.dart');
      }
      _seal(changed);
      if (['branch', 'no-op', 'gap'].contains(mutation))
        validateProvenanceStage(changed);
      if (mutation == 'identity') changed['candidate_identity'] = hash;
      expect(
          () => verifySourceStages(id, initial, terminal, stages: [
                ...stages.where((s) => s['task'] != history['task']),
                changed,
              ]),
          throwsStateError,
          reason: mutation);
    }
    for (final selection in [
      [...stages, history],
      for (final omitted in stages)
        stages.where((s) => s['task'] != omitted['task']).toList(),
    ]) {
      expect(() => verifySourceStages(id, initial, terminal, stages: selection),
          throwsStateError);
    }
    // Construct two individually policy-valid stages changing only the shared
    // helper. Their complete bundles form a true cycle with no root.
    final cycle = _copy(history);
    final predecessor = _copy(keyboard);
    const helper = 'test/migration/support/provenance_transition.dart';
    for (final name in (cycle['binding_maps'] as Map).keys) {
      final before = _copy(keyboard['binding_maps'][name]['before'] as Map);
      final after = _copy(before);
      if (after.containsKey(helper)) after[helper] = hash;
      predecessor['binding_maps'][name]['before'] = _copy(before);
      predecessor['binding_maps'][name]['after'] = _copy(after);
      cycle['binding_maps'][name]['before'] = _copy(after);
      cycle['binding_maps'][name]['after'] = _copy(before);
    }
    for (final stage in [predecessor, cycle]) {
      _seal(stage);
      validateProvenanceStage(stage);
    }
    expect(
        () => verifySourceStages(
            id, predecessor['binding_maps'][id]['before'] as Map, terminal,
            stages: [cycle, predecessor]),
        throwsStateError);
  });

  test('a rooted full-bundle cycle cannot revisit an already consumed bundle',
      () {
    final stages = readProvenanceStages();
    final keyboard =
        stages.singleWhere((s) => s['task'] == 'MAINT-PRESET-KEYBOARD-01');
    final root = _copy(keyboard);
    final outgoing = _copy(
        stages.singleWhere((s) => s['task'] == 'HISTORY-COMMIT-REPLAY-01'));
    final returning = _copy(stages.singleWhere((s) => s['task'] == 'ACAD-015'));
    const helper = 'test/migration/support/provenance_transition.dart';
    // A -> B -> C -> B has one root and one unconsumed successor at each
    // step. Consuming each stage once is insufficient to reject this cycle.
    for (final id in (keyboard['binding_maps'] as Map).keys) {
      final a = _copy(keyboard['binding_maps'][id]['before'] as Map);
      final b = _copy(a);
      final c = _copy(a);
      if (a.containsKey(helper)) {
        b[helper] = 'b' * 64;
        c[helper] = 'c' * 64;
      }
      root['binding_maps'][id]['before'] = a;
      root['binding_maps'][id]['after'] = b;
      outgoing['binding_maps'][id]['before'] = _copy(b);
      outgoing['binding_maps'][id]['after'] = c;
      returning['binding_maps'][id]['before'] = _copy(c);
      returning['binding_maps'][id]['after'] = _copy(b);
    }
    for (final stage in [root, outgoing, returning]) {
      _seal(stage);
      validateProvenanceStage(stage);
    }
    for (final id in (root['binding_maps'] as Map).keys.cast<String>()) {
      for (final order in [
        [root, outgoing, returning],
        [returning, root, outgoing],
      ]) {
        expect(
            () => verifySourceStages(
                id,
                root['binding_maps'][id]['before'] as Map,
                returning['binding_maps'][id]['after'] as Map,
                stages: order),
            throwsStateError,
            reason: id);
      }
    }
  });

  test(
      'preset policy rejects self-consistent malicious stages and broken chains',
      () {
    final stages = readProvenanceStages()
        .where((s) => s['task'] != 'HISTORY-COMMIT-REPLAY-01')
        .toList();
    final task =
        stages.singleWhere((s) => s['task'] == 'MAINT-PRESET-KEYBOARD-01');
    const id = 'physical-events';
    final initial = stages.first['binding_maps'][id]['before'] as Map;
    final current = task['binding_maps'][id]['after'] as Map;
    const hash =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    const preset = 'lib/features/presets/preset_sheet.dart';
    const helper = 'test/migration/support/provenance_transition.dart';
    const unrelated = 'lib/core/controllers/fractal_controller.dart';
    for (final mutation in [
      'unknown-task',
      'widen-policy',
      'unlisted-change',
      'unlisted-add',
      'unlisted-remove',
      'preset-remove',
      'helper-remove',
      'gap',
      'changed-set',
      'added-set',
      'removed-set',
      'identity',
      'retained-anchor',
      'original-anchor',
      'original-revision',
      'change-reference',
      'missing-map',
      'extra-map',
      'extra-key',
    ]) {
      final stage = _copy(task);
      final record = stage['binding_maps'][id] as Map;
      final after = record['after'] as Map;
      switch (mutation) {
        case 'unknown-task':
          stage['task'] = 'UNKNOWN';
        case 'widen-policy':
          stage['allowed_paths'].add(unrelated);
          after[unrelated] = hash;
        case 'unlisted-change':
          after[unrelated] = hash;
        case 'unlisted-add':
          after['unexpected.dart'] = hash;
        case 'unlisted-remove':
          after.remove(unrelated);
        case 'preset-remove':
          after.remove(preset);
        case 'helper-remove':
          after.remove(helper);
        case 'gap':
          record['before'][preset] = hash;
      }
      // Recompute all claimed deltas/identity so policy and adjacency, not stale
      // bookkeeping, must reject these malicious documents.
      _seal(stage);
      switch (mutation) {
        case 'changed-set':
          record['changed'] = [];
        case 'added-set':
          record['added'] = [preset];
        case 'removed-set':
          record['removed'] = [preset];
        case 'identity':
          stage['candidate_identity'] = hash;
        case 'retained-anchor':
          stage['retained_document_hashes']['modules'] = hash;
        case 'original-anchor':
          stage['original_fixture_hashes']['modules'] = hash;
        case 'original-revision':
          stage['original_revision'] = 'changed';
        case 'change-reference':
          stage['change_reference'] = 'other.md';
        case 'missing-map':
          stage['binding_maps'].remove('presets');
        case 'extra-map':
          stage['binding_maps']['unexpected'] = _copy(record);
        case 'extra-key':
          stage['unexpected'] = true;
      }
      expect(
          () => verifySourceStages(id, initial, after, stages: [
                ...stages.where((s) => s['task'] != task['task']),
                stage,
              ]),
          throwsStateError,
          reason: mutation);
    }
    for (final selection in <List<Map>>[
      [],
      [...stages, task],
      for (final omitted in stages)
        stages.where((s) => s['task'] != omitted['task']).toList(),
    ]) {
      expect(() => verifySourceStages(id, initial, current, stages: selection),
          throwsStateError,
          reason: 'missing/duplicate stage');
    }
    // An identity attaches at the terminal cursor, not to an earlier map. Two
    // independently valid identities at that cursor must remain ambiguous.
    final identity = _copy(task);
    final competitor =
        _copy(stages.singleWhere((s) => s['task'] == 'ACAD-015-BASELINE'));
    for (final stage in [identity, competitor]) {
      for (final mapId in (stage['binding_maps'] as Map).keys) {
        final record = stage['binding_maps'][mapId] as Map;
        record['before'] = _copy(task['binding_maps'][mapId]['after'] as Map);
        record['after'] = _copy(record['before'] as Map);
      }
      _seal(stage);
      validateProvenanceStage(stage);
    }
    expect(
        () => verifySourceStages(id, current, current,
            stages: [identity, competitor]),
        throwsStateError);
    expect(
        () => verifySourceStages(id, initial, current,
            stages: [...stages, competitor]),
        throwsStateError);
  });
}
