import 'dart:convert';
import 'dart:io';

// Reuse the locked hashing dependency and baseline's canonical JSON convention.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';

import 'baseline_inventory.dart' show canonicalJson;

const referenceTransitionPath =
    'migration/oracles/reference-source-transitions.json';
const _changedPaths = {
  'lib/features/renderer/widgets/renderer/fractal_renderer.dart',
  'lib/features/renderer/widgets/renderer/input/gesture_handler.dart',
  'test/migration/support/reference_capture.dart',
};
const _addedPaths = {'test/migration/support/reference_source_transition.dart'};

String _hash(List<int> bytes) => sha256.convert(bytes).toString();

/// Inventory every original fixture, not only the manifest or decoded pixels.
Map<String, String> referenceFixtureHashes() => {
      for (final file in Directory('migration/baseline')
          .listSync(recursive: true)
          .whereType<File>())
        file.path: _hash(file.readAsBytesSync()),
    };

Map<String, dynamic> readReferenceSourceTransition() =>
    jsonDecode(File(referenceTransitionPath).readAsStringSync())
        as Map<String, dynamic>;

/// One exact clock-seam transition, not a general source-drift waiver.
/// Both complete source maps and every original fixture byte remain mandatory.
void validateReferenceSourceTransition({
  required Map transition,
  required Map retainedSources,
  required Map currentSources,
  required Map fixtureHashes,
}) {
  expect(
      transition.keys,
      unorderedEquals([
        'schema',
        'task',
        'scope',
        'before_source_bindings',
        'after_source_bindings',
        'fixture_files_sha256',
      ]));
  expect(transition['schema'], 1);
  expect(transition['task'], 'RUST-M2-PHYSICAL-ORACLE');
  expect(
      transition['scope'], 'gesture-clock-only; unchanged reference fixtures');
  final fixtures = transition['fixture_files_sha256'] as Map;
  expect(fixtures, fixtureHashes);
  // Independent immutable anchor: a mutated sidecar cannot bless new fixtures.
  expect(_hash(utf8.encode(canonicalJson(fixtures))),
      '2c79a71ca7a8479e207daa3c4ae2377e7d85bbae41a305218003874967f0da3f');
  final before = transition['before_source_bindings'] as Map;
  final after = transition['after_source_bindings'] as Map;
  expect(before, retainedSources, reason: 'Complete retained source map');
  expect(after, currentSources, reason: 'Complete current source map');
  final removed = before.keys.toSet().difference(after.keys.toSet());
  final added = after.keys.toSet().difference(before.keys.toSet());
  final changed = before.keys
      .where((key) => after.containsKey(key) && before[key] != after[key])
      .toSet();
  expect(removed, isEmpty, reason: 'No source binding may be removed');
  expect(added, _addedPaths, reason: 'Only the transition helper is added');
  expect(changed, _changedPaths,
      reason: 'Only the clock seam and its guard change');
}
