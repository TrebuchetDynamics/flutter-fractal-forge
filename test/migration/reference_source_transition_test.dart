import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';
import 'support/reference_capture.dart';
import 'support/reference_source_transition.dart';
import 'support/provenance_transition.dart';

void main() {
  test(
      'exact clock transition preserves fixtures and rejects provenance mutation',
      () {
    final sidecarBytes = File(referenceTransitionPath).readAsStringSync();
    final transition = readReferenceSourceTransition();
    final inventory = buildBaselineInventory();
    final current = captureReferenceSources(
        (inventory['modules']!['provenance'] as Map)['sources'] as Map);
    final fixtures = referenceFixtureHashes();
    final retained =
        readManifest(referenceRoot)['provenance']['source_bindings'] as Map;
    void validate(
            {Map? document,
            Map? sources,
            Map? files,
            Map? original,
            List<Map>? stages}) =>
        expect(
            () => validateReferenceComposition(
                  clock: document ?? transition,
                  retainedSources: original ?? retained,
                  currentSources: sources ?? current,
                  fixtureHashes: files ?? fixtures,
                  stages: stages,
                  validateClock: (after, originals) =>
                      validateReferenceSourceTransition(
                    transition: document ?? transition,
                    retainedSources: original ?? retained,
                    currentSources: after,
                    fixtureHashes: originals,
                  ),
                ),
            returnsNormally);
    validate();
    validate(
        original: readManifest('$referenceRoot/first-capture')['provenance']
            ['source_bindings'] as Map);
    Map copy() => jsonDecode(canonicalJson(transition)) as Map;
    const unrelated = 'lib/core/controllers/fractal_controller.dart';
    const clock =
        'lib/features/renderer/widgets/renderer/fractal_renderer.dart';
    for (final field in ['before_source_bindings', 'after_source_bindings']) {
      for (final mutation in ['changed', 'added', 'removed']) {
        final changed = copy();
        final map = changed[field] as Map;
        switch (mutation) {
          case 'changed':
            map[clock] = 'mutated';
          case 'added':
            map['unrelated.dart'] = 'mutated';
          case 'removed':
            map.remove(unrelated);
        }
        expect(() => validate(document: changed), throwsA(isA<TestFailure>()),
            reason: '$field/$mutation');
      }
    }
    for (final mutation in ['changed', 'added', 'removed']) {
      final sources = Map.from(current);
      switch (mutation) {
        case 'changed':
          sources[unrelated] = 'mutated';
        case 'added':
          sources['unrelated.dart'] = 'mutated';
        case 'removed':
          sources.remove(unrelated);
      }
      expect(() => validate(sources: sources), throwsA(isA<TestFailure>()));
      // Even editing the sidecar to match cannot authorize unrelated drift.
      final changed = copy()..['after_source_bindings'] = sources;
      expect(() => validate(document: changed, sources: sources),
          throwsA(isA<TestFailure>()),
          reason: 'unrelated $mutation');
    }
    for (final path in [
      '$referenceRoot/manifest.json',
      '$referenceRoot/first-capture/manifest.json',
      '$referenceRoot/mandelbrot.png',
      '$referenceRoot/first-capture/mandelbrot.png',
      'migration/baseline/modules.json',
    ]) {
      final files = Map.from(fixtures)..[path] = 'mutated';
      expect(() => validate(files: files), throwsA(isA<TestFailure>()));
      final changed = copy()..['fixture_files_sha256'] = files;
      expect(() => validate(document: changed, files: files),
          throwsA(isA<TestFailure>()),
          reason: 'immutable fixture anchor: $path');
    }
    for (final field in ['schema', 'task', 'scope']) {
      final changed = copy()..[field] = 'mutated';
      expect(() => validate(document: changed), throwsA(isA<TestFailure>()));
    }
    final missing = copy()..remove('after_source_bindings');
    expect(() => validate(document: missing), throwsA(isA<TestFailure>()));
    Map stageCopy() =>
        jsonDecode(canonicalJson(readProvenanceTransition())) as Map;
    void seal(Map stage) {
      for (final r in (stage['binding_maps'] as Map).values.cast<Map>()) {
        final a = r['before'] as Map, b = r['after'] as Map;
        r['changed'] = a.keys
            .where((k) => b.containsKey(k) && a[k] != b[k])
            .toList()
          ..sort();
        r['added'] = b.keys.toSet().difference(a.keys.toSet()).toList()..sort();
        r['removed'] = a.keys.toSet().difference(b.keys.toSet()).toList()
          ..sort();
      }
      stage['candidate_identity'] = objectHash({
        for (final e in (stage['binding_maps'] as Map).entries)
          e.key: e.value['after'],
      });
    }

    const changedHash =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    for (final mutation in [
      'unlisted-change',
      'unlisted-add',
      'unlisted-remove',
      'allowed-remove',
      'gap',
      'wrong-task-policy',
      'delta-set',
      'identity',
      'anchor',
      'historical',
    ]) {
      final stage = stageCopy();
      final r = stage['binding_maps']['reference'] as Map;
      final after = r['after'] as Map;
      switch (mutation) {
        case 'unlisted-change':
          after[unrelated] = changedHash;
        case 'unlisted-add':
          after['unexpected.dart'] = changedHash;
        case 'unlisted-remove':
          after.remove(unrelated);
        case 'allowed-remove':
          after.remove('pubspec.lock');
        case 'gap':
          r['before']['pubspec.lock'] = changedHash;
        case 'wrong-task-policy':
          after['lib/l10n/app_localizations_en.dart'] = changedHash;
      }
      seal(stage);
      if (mutation == 'delta-set') r['changed'] = [];
      if (mutation == 'identity') stage['candidate_identity'] = changedHash;
      if (mutation == 'anchor')
        stage['retained_document_hashes']['modules'] = changedHash;
      if (mutation == 'historical')
        stage['historical_custody']['maps']['inventory']['original']
            [unrelated] = changedHash;
      expect(() => validate(stages: [stage], sources: after),
          throwsA(isA<TestFailure>()),
          reason: 'self-consistent stage mutation: $mutation');
    }
    expect(() => validate(stages: [stageCopy(), stageCopy()]),
        throwsA(isA<TestFailure>()));
    expect(() => validate(stages: []), throwsA(isA<TestFailure>()));
    // Both integration orders must work, but a disconnected sibling cannot be ignored.
    for (final bootstrapFirst in [true, false]) {
      final bootstrap = stageCopy();
      final sibling = (stageCopy()..remove('historical_custody'))
        ..['task'] = 'MAINT-A11Y-STATUS-COPY-01'
        ..['allowed_paths'] = [
          'lib/l10n/app_localizations.dart',
          'lib/l10n/app_localizations_en.dart',
          'lib/l10n/app_localizations_es.dart',
          ...bootstrapBindingAllowlist.skip(2),
        ];
      for (final id in (bootstrap['binding_maps'] as Map).keys) {
        final b = bootstrap['binding_maps'][id] as Map;
        final initial = Map.from(b['before'] as Map);
        final terminal = Map.from(b['after'] as Map);
        const path = 'lib/l10n/app_localizations_en.dart';
        final first = bootstrapFirst ? terminal : initial;
        final changed = Map.from(first)..[path] = changedHash;
        sibling['binding_maps'][id]['before'] = first;
        sibling['binding_maps'][id]['after'] = changed;
        if (!bootstrapFirst) {
          b['before'] = changed;
          b['after'] = Map.from(terminal)..[path] = changedHash;
        }
      }
      seal(bootstrap);
      seal(sibling);
      final sources =
          Map.from(bootstrap['binding_maps']['reference']['after'] as Map)
            ..['lib/l10n/app_localizations_en.dart'] = changedHash;
      validate(stages: [sibling, bootstrap], sources: sources);
      final broken = jsonDecode(canonicalJson(sibling)) as Map;
      broken['binding_maps']['reference']['before']['pubspec.lock'] =
          changedHash;
      seal(broken);
      expect(() => validate(stages: [broken, bootstrap], sources: sources),
          throwsA(isA<TestFailure>()),
          reason: 'disconnected sibling');
    }
    final a11y = readProvenanceStages()
        .singleWhere((stage) => stage['task'] == 'MAINT-A11Y-STATUS-COPY-01');
    for (final mutation in [
      'unlisted-change',
      'unlisted-add',
      'unlisted-remove',
      'allowed-remove',
      'gap',
      'wrong-task-policy',
      'delta-set',
      'identity',
      'anchor',
    ]) {
      final stage = jsonDecode(canonicalJson(a11y)) as Map;
      final record = stage['binding_maps']['reference'] as Map;
      final after = record['after'] as Map;
      switch (mutation) {
        case 'unlisted-change':
          after[unrelated] = changedHash;
        case 'unlisted-add':
          after['unexpected.dart'] = changedHash;
        case 'unlisted-remove':
          after.remove(unrelated);
        case 'allowed-remove':
          after.remove('lib/l10n/app_localizations_en.dart');
        case 'gap':
          record['before']['lib/l10n/app_localizations_en.dart'] = changedHash;
        case 'wrong-task-policy':
          after['pubspec.lock'] = changedHash;
      }
      seal(stage);
      if (mutation == 'delta-set') record['changed'] = [];
      if (mutation == 'identity') stage['candidate_identity'] = changedHash;
      if (mutation == 'anchor')
        stage['original_fixture_hashes']['modules'] = changedHash;
      expect(() => validate(stages: [stageCopy(), stage], sources: after),
          throwsA(isA<TestFailure>()),
          reason: 'self-consistent accessibility stage mutation: $mutation');
    }
    for (final path in [
      'migration/baseline/original/modules.json',
      'migration/baseline/original/unknown.json',
      'migration/baseline/unknown.json',
      bootstrapTransitionPath,
    ]) {
      final changed = Map.from(fixtures)..[path] = changedHash;
      expect(() => validate(files: changed), throwsA(isA<TestFailure>()),
          reason: path);
      final missing = Map.from(fixtures)..remove(path);
      if (fixtures.containsKey(path)) {
        expect(() => validate(files: missing), throwsA(isA<TestFailure>()),
            reason: 'missing $path');
      }
    }
    expect(File(referenceTransitionPath).readAsStringSync(), sidecarBytes);
    expect(referenceFixtureHashes(), fixtures);
  });
}
