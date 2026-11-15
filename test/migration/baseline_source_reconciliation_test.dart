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
    expect(stages.length, 5);
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
      for (final path in expectedChanged) {
        if (path == 'test/migration/support/provenance_transition.dart') {
          expect(record['after'][path],
              '27778ec2aae6a2efd9db99e851a4e6d7cd7ddcbcaaf63e0483370de3fd839659',
              reason: 'Original historical source binding remains exact');
          expect(readVisualStages().last['binding_maps'][id]['after'][path],
              sha256.convert(File(path).readAsBytesSync()).toString(),
              reason: 'Candidate is bound independently, not repinned history');
        } else {
          expect(record['after'][path],
              sha256.convert(File(path).readAsBytesSync()).toString());
        }
      }
      verifySourceStages(id, stages.first['binding_maps'][id]['before'] as Map,
          record['after'] as Map,
          stages: stages.reversed.toList());
    }
  });

  test(
      'preset policy rejects self-consistent malicious stages and broken chains',
      () {
    final stages = readProvenanceStages();
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
