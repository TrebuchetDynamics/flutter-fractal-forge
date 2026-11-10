import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/baseline_inventory.dart';
import 'support/reference_capture.dart';
import 'support/reference_source_transition.dart';

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
    void validate({Map? document, Map? sources, Map? files, Map? original}) =>
        validateReferenceSourceTransition(
          transition: document ?? transition,
          retainedSources: original ?? retained,
          currentSources: sources ?? current,
          fixtureHashes: files ?? fixtures,
        );
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
    expect(File(referenceTransitionPath).readAsStringSync(), sidecarBytes);
    expect(referenceFixtureHashes(), fixtures);
  });
}
