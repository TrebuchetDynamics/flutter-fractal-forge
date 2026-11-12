import 'dart:convert';
import 'dart:io';

// Reuse the locked comparison/hash dependencies without expanding local collectors.
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

const bootstrapTransitionPath =
    'migration/baseline/provenance-transitions.json';
const _a11yTransitionPath =
    'migration/oracles/a11y-status-copy-source-transitions.json';
const _baselineThemeTransitionPath =
    'migration/oracles/acad-015-baseline-source-transitions.json';
const _quietThemeTransitionPath =
    'migration/oracles/acad-015-source-transitions.json';
const _clockPath = 'migration/oracles/reference-source-transitions.json';
const _changeReference =
    'docs/tasks/source-bound-review-gates.md#scoped-reconciliation--2026-11-10';
const _harnessPaths = [
  'test/migration/baseline_contracts_test.dart',
  'test/migration/state_replay_test.dart',
  'test/migration/param_interpolation_oracle_test.dart',
  'test/migration/physical_events_oracle_test.dart',
  'test/migration/randomization_oracle_test.dart',
  'test/migration/reference_source_transition_test.dart',
  'test/migration/support/reference_capture.dart',
  'test/migration/support/provenance_transition.dart',
];
const bootstrapBindingAllowlist = [
  'pubspec.yaml',
  'pubspec.lock',
  ..._harnessPaths
];
const _a11yBindingAllowlist = [
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_es.dart',
  ..._harnessPaths,
];
const _baselineThemeBindingAllowlist = [
  'lib/features/controls/widgets/number_wall_style_controls.dart',
  'lib/features/presets/preset_sheet.dart',
  'lib/features/viewer/chrome/fractal_controls_hud.dart',
  'lib/features/viewer/chrome/fractal_view_controls.dart',
  'lib/features/viewer/chrome/viewer_tools.dart',
  'lib/features/viewer/diagnostics/viewer_debug_report.dart',
  'lib/features/viewer/export/viewer_export_overlay.dart',
  'lib/features/viewer/fractal_viewer_screen.dart',
  'lib/features/viewer/gaussian_moat_map.dart',
  'lib/features/viewer/overlays/viewer_hud.dart',
];
const _quietThemeBindingAllowlist = [
  'lib/core/theme/app_theme.dart',
  'lib/features/viewer/overlays/auto_pilot_alignment_overlay.dart',
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_es.dart',
  'test/migration/support/provenance_transition.dart',
];
const originalFixtureHashes = {
  'capabilities':
      '1753218c708ce12f90132e5429af616f46dc5cc7d6a49358ae81c393f4b38e3b',
  'modules': '40f56b81443379ce8a983824d54d15b01aa6707c084e9b11dbc4e0eca511149b',
  'parameters':
      'dafc4ae9f2e364967cfb1d49b149679706df9d1ce8aeb69fb8257e2f894e0da6',
  'precision-replay':
      '5ed9d716e3460c45d98bb90a188352a5cf0c4cd04fec03085b3f4aa804b6bbff',
  'presets': '0cc92e415d3317b112caa460f0fb9e9ef6e8d75980aac5deffbfd0e9cc1bf997',
  'shader-contracts':
      '46fcb517b7efd096f3b2902a93860eae19de7c34929820799ce3f832a8f5b6bf',
  'state-replay':
      'b107f23b8a1175e80b6dbf44637adee7d83e37d0f0b7632f1c0ee3892fa3c46d',
};
const beforeFixtureHashes = {
  'capabilities':
      '5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa',
  'modules': '571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3',
  'parameters':
      '5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517',
  'precision-replay':
      'a8e7537f72687e58c1093015af619246612ce37974322249fba89ce34bcfbe2a',
  'presets': '318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e',
  'shader-contracts':
      '2853d6d7958ea8cbbbc0cf609725644debb99b626cc80152832a10e8e1b0dfc2',
  'state-replay':
      '0af9a0422763e45bab6b4410e4f549e8e809515a2288a8741fbf2cb87be705a3',
};
const _otherDocumentHashes = {
  'param-interpolation':
      'd8e28e5a10de0c6e790398334cc058c29dd16f20959cf3a694b102273bc82752',
  'physical-events':
      'ec46427fff067ec864540506827ebd47ae6d083b176ee945b80ddd8f7d6a95ec',
  'randomization':
      '3c82155a721e193b12fbf73915cd1760423ba0449bead6546723461beec95db1',
  'reference-manifest':
      '9e53d5bc7d2e3665be54f075ffa304b9e9b9a3134b2007d8bf0fbe1ee640431c',
  'reference-first-manifest':
      'a6f24a9c2822a330256acdc9658ee339e1ddb2405f5b4fd8f502357d490e4797',
};
final _retainedHashes = {...beforeFixtureHashes, ..._otherDocumentHashes};
final _mapNames = {
  ...beforeFixtureHashes.keys,
  'param-interpolation',
  'physical-events',
  'randomization',
  'reference'
};
const _equal = DeepCollectionEquality();
String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
String _canonical(Object? value) {
  Object? sort(Object? v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: sort(v[k])};
    }
    return v is List ? v.map(sort).toList() : v;
  }

  return '${const JsonEncoder.withIndent('  ').convert(sort(value))}\n';
}

void _require(bool valid, String message) {
  if (!valid) throw StateError('Provenance: $message');
}

Map<String, dynamic> readProvenanceTransition() =>
    jsonDecode(File(bootstrapTransitionPath).readAsStringSync())
        as Map<String, dynamic>;
List<Map> readProvenanceStages() => [
      for (final path in [
        bootstrapTransitionPath,
        _a11yTransitionPath,
        _baselineThemeTransitionPath,
        _quietThemeTransitionPath,
      ])
        if (File(path).existsSync())
          jsonDecode(File(path).readAsStringSync()) as Map,
    ];

void _checkDelta(Map before, Map after, Set<String> allowed) {
  _require(before.keys.toSet().difference(after.keys.toSet()).isEmpty,
      'removed binding');
  for (final key in after.keys) {
    _require(
        before.containsKey(key) && before[key] == after[key] ||
            allowed.contains(key),
        'unauthorized binding $key');
  }
}

/// Each stage has its own policy; complete-map adjacency decides integration order.
void validateProvenanceStage(Map stage) {
  _require(
      _equal.equals(stage.keys.toSet(), {
        'schema',
        'task',
        'change_reference',
        'base_revision',
        'candidate_identity',
        'allowed_paths',
        'retained_document_hashes',
        'original_revision',
        'original_fixture_hashes',
        'binding_maps',
        if (stage['task'] == 'RUST-CORE-BOOTSTRAP') 'historical_custody',
      }),
      'stage schema keys');
  final task = stage['task'];
  final allowed = switch (task) {
    'RUST-CORE-BOOTSTRAP' => bootstrapBindingAllowlist,
    'MAINT-A11Y-STATUS-COPY-01' => _a11yBindingAllowlist,
    'ACAD-015-BASELINE' => _baselineThemeBindingAllowlist,
    'ACAD-015' => _quietThemeBindingAllowlist,
    _ => throw StateError('Provenance: unknown task $task'),
  };
  _require(
      stage['schema'] == 2 &&
          stage['change_reference'] ==
              switch (task) {
                'ACAD-015-BASELINE' =>
                  'docs/tasks/source-bound-review-gates.md#acad-015-baseline-provenance-repair',
                'ACAD-015' =>
                  'docs/tasks/source-bound-review-gates.md#acad-015-quiet-theme-and-crosshair-localization',
                _ => _changeReference,
              } &&
          RegExp(r'^[0-9a-f]{40}$')
              .hasMatch(stage['base_revision'] as String) &&
          _equal.equals(stage['allowed_paths'], allowed) &&
          _equal.equals(stage['retained_document_hashes'], _retainedHashes) &&
          stage['original_revision'] == '8345b8e2' &&
          _equal.equals(
              stage['original_fixture_hashes'], originalFixtureHashes),
      'stage identity/anchors/policy');
  if (task == 'RUST-CORE-BOOTSTRAP') {
    final history = stage['historical_custody'] as Map;
    _require(
        _equal.equals(history.keys.toSet(), {'reference', 'maps'}) &&
            history['reference'] == '7a29d17b / 8d7b547d / 76868732',
        'historical identity');
    final records = history['maps'] as Map;
    _require(_equal.equals(records.keys.toSet(), {'inventory', 'replay'}),
        'historical maps');
    for (final entry in {
      'inventory': (
        'modules',
        'aecea8964150171de980231ae59f9f4fbce828c402d47bd3d3bae735d1687e5a'
      ),
      'replay': (
        'state-replay',
        '60929c7850310e6e875bf0ad0b47ac062fd1549cefc406e3c5aea65a78455032'
      ),
    }.entries) {
      final record = records[entry.key] as Map;
      _require(
          _equal.equals(record.keys.toSet(),
              {'original', 'before', 'changed', 'added', 'removed'}),
          'historical record keys');
      final original = record['original'] as Map,
          before = record['before'] as Map;
      _require(_hash(_canonical(original)) == entry.value.$2,
          'historical original map anchor');
      final bytes =
          File('migration/baseline/${entry.value.$1}.json').readAsStringSync();
      verifyRetainedBytes(entry.value.$1, bytes);
      _require(_equal.equals(before, _bindings(jsonDecode(bytes) as Map)),
          'historical before map');
      _checkDelta(original, before, {
        'pubspec.yaml',
        'pubspec.lock',
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag'
      });
      final changed =
          original.keys.where((k) => before[k] != original[k]).toList()..sort();
      final added = before.keys
          .toSet()
          .difference(original.keys.toSet())
          .toList()
        ..sort();
      _require(
          _equal.equals(record['changed'], changed) &&
              _equal.equals(record['added'], added) &&
              _equal.equals(record['removed'], []),
          'historical delta sets');
    }
  }
  final maps = stage['binding_maps'] as Map;
  _require(
      _equal.equals(maps.keys.toSet(), _mapNames), 'complete map inventory');
  for (final record in maps.values.cast<Map>()) {
    _require(
        _equal.equals(record.keys.toSet(),
            {'before', 'after', 'changed', 'added', 'removed'}),
        'map record keys');
    final before = record['before'] as Map, after = record['after'] as Map;
    for (final map in [before, after]) {
      _require(
          map.isNotEmpty &&
              map.keys.every((k) => k is String) &&
              map.values.every(
                  (v) => v is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(v)),
          'binding hash format');
    }
    final changed = before.keys
        .where((k) => after.containsKey(k) && before[k] != after[k])
        .cast<String>()
        .toList()
      ..sort();
    final added = after.keys
        .toSet()
        .difference(before.keys.toSet())
        .cast<String>()
        .toList()
      ..sort();
    _require(
        _equal.equals(changed, record['changed']) &&
            _equal.equals(added, record['added']) &&
            _equal.equals(record['removed'], []),
        'exact delta sets');
    _checkDelta(before, after, allowed.toSet());
  }
  _require(
      stage['candidate_identity'] ==
          _hash(_canonical({
            for (final id in maps.keys) id: maps[id]['after'],
          })),
      'candidate binding identity');
}

void verifySourceStages(String id, Map before, Map current,
    {List<Map>? stages}) {
  final pending = [...(stages ?? readProvenanceStages())];
  _require(
      pending.isNotEmpty &&
          pending.map((s) => s['task']).toSet().length == pending.length,
      'missing/duplicate stages');
  for (final stage in pending) {
    validateProvenanceStage(stage);
  }
  Map cursor = before;
  while (pending.isNotEmpty) {
    final adjacent = pending
        .where((s) => _equal.equals(s['binding_maps'][id]['before'], cursor))
        .toList();
    // A scoped stage can leave this map unchanged; consume it before advancing.
    final unchanged = adjacent
        .where((s) => _equal.equals(s['binding_maps'][id]['after'], cursor))
        .toList();
    final next = unchanged.isEmpty ? adjacent : unchanged;
    _require(next.length == 1, 'broken/ambiguous stage adjacency for $id');
    final stage = next.single;
    cursor = stage['binding_maps'][id]['after'] as Map;
    pending.remove(stage);
  }
  _require(
      _equal.equals(cursor, current), 'complete current map mismatch for $id');
}

Map _bindings(Map document) {
  if (document.containsKey('provenance')) {
    final provenance = document['provenance'] as Map;
    return (provenance['sources'] ?? provenance['source_bindings']) as Map;
  }
  return document['source_bindings'] as Map;
}

Map _withBindings(Map document, Map bindings) {
  final copy = jsonDecode(jsonEncode(document)) as Map;
  if (copy.containsKey('provenance')) {
    final p = copy['provenance'] as Map;
    _require(p['source_set_sha256'] == _hash(_canonical(_bindings(document))),
        'source-set digest');
    p[p.containsKey('sources') ? 'sources' : 'source_bindings'] = bindings;
    p['source_set_sha256'] = _hash(_canonical(bindings));
  } else {
    copy['source_bindings'] = bindings;
  }
  return copy;
}

void verifyRetainedBytes(String name, String bytes) {
  _require(_hash(bytes) == _retainedHashes[name], 'retained bytes $name');
  _require(
      _canonical(jsonDecode(bytes)) == bytes, 'retained canonical bytes $name');
}

void verifyBoundDocument(String name, String beforeBytes, Map generated,
    {List<Map>? stages, String? originalBytes}) {
  verifyRetainedBytes(name, beforeBytes);
  final before = jsonDecode(beforeBytes) as Map;
  final selected = stages ?? readProvenanceStages();
  if (originalFixtureHashes.containsKey(name) &&
      (originalBytes != null ||
          selected.any((s) => s['task'] == 'RUST-CORE-BOOTSTRAP'))) {
    final originalText = originalBytes ??
        File('migration/baseline/original/$name.json').readAsStringSync();
    _require(_hash(originalText) == originalFixtureHashes[name],
        'original fixture $name');
    final original = jsonDecode(originalText) as Map;
    _checkDelta(_bindings(original), _bindings(before), {
      'pubspec.yaml',
      'pubspec.lock',
      'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag',
    });
    _require(
        _canonical(_withBindings(original, _bindings(before))) ==
            _canonical(before),
        'historical nonbinding drift');
  }
  verifySourceStages(name, _bindings(before), _bindings(generated),
      stages: selected);
  _require(
      _canonical(_withBindings(before, _bindings(generated))) ==
          _canonical(generated),
      'semantic/metadata drift $name');
  // Validate the current digest too; replacement must not hide a corrupt digest.
  _withBindings(generated, _bindings(generated));
  recordProvenanceObservation(name, before, generated);
}

// Preserve the original public comparator seam and its mutation cases.
void verifyProvenanceTransition(String name, String beforeBytes,
        Map<String, Object?> generated, Map<String, dynamic> transition,
        {String? originalBytes}) =>
    verifyBoundDocument(name, beforeBytes, generated,
        stages: [
          transition,
          for (final stage in readProvenanceStages())
            if (stage['task'] != transition['task']) stage,
        ],
        originalBytes: originalBytes);

/// Partition additions here, never by filtering the collector or clock validator.
Map validateBaselineCustody(Map clock, Map fixtureHashes, {List<Map>? stages}) {
  final selected = stages ?? readProvenanceStages();
  for (final stage in selected) {
    validateProvenanceStage(stage);
  }
  final original = clock['fixture_files_sha256'] as Map;
  final bootstrap = selected.any((s) => s['task'] == 'RUST-CORE-BOOTSTRAP');
  final archives = {
    if (bootstrap)
      for (final entry in originalFixtureHashes.entries)
        'migration/baseline/original/${entry.key}.json': entry.value
  };
  final expected = {
    ...original.keys,
    ...archives.keys,
    if (bootstrap) bootstrapTransitionPath
  };
  _require(_equal.equals(fixtureHashes.keys.toSet(), expected),
      'unknown/missing baseline file');
  for (final entry in archives.entries) {
    _require(
        fixtureHashes[entry.key] == entry.value &&
            sha256.convert(File(entry.key).readAsBytesSync()).toString() ==
                entry.value,
        'archive custody ${entry.key}');
  }
  if (bootstrap) {
    final file = File(bootstrapTransitionPath);
    _require(
        fixtureHashes[bootstrapTransitionPath] ==
            sha256.convert(file.readAsBytesSync()).toString(),
        'sidecar file hash');
    validateProvenanceStage(jsonDecode(file.readAsStringSync()) as Map);
  }
  return {for (final key in original.keys) key: fixtureHashes[key]};
}

void validateReferenceComposition(
    {required Map clock,
    required Map retainedSources,
    required Map currentSources,
    required Map fixtureHashes,
    required void Function(Map clockAfter, Map originals) validateClock,
    List<Map>? stages}) {
  final clockBytes = File(_clockPath).readAsStringSync();
  _require(
      _hash(clockBytes) ==
              '3f0ef636f99c644a924df893ef673977f95c4a0558a5fdff29d4d6b8668e65a5' &&
          _equal.equals(jsonDecode(clockBytes), clock),
      'immutable clock sidecar');
  final originals =
      validateBaselineCustody(clock, fixtureHashes, stages: stages);
  final clockAfter = clock['after_source_bindings'] as Map;
  // The callback is the unchanged validator; retainedSources remains caller-bound.
  _require(_equal.equals(clock['before_source_bindings'], retainedSources),
      'clock stage start');
  validateClock(clockAfter, originals);
  verifySourceStages('reference', clockAfter, currentSources, stages: stages);
}

/// Private scratch readback only. Every observation is already fully validated.
void recordProvenanceObservation(String name, Map before, Map current) {
  const output = String.fromEnvironment('MIGRATION_TRANSITION_OUT');
  if (output.isEmpty) return;
  final directory = Directory(output);
  _require(directory.isAbsolute, 'scratch path must be absolute');
  directory.createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  final root = Directory.current.resolveSymbolicLinksSync();
  _require(resolved != root && !resolved.startsWith('$root/'),
      'scratch must be external');
  final file = File('$resolved/$name.json');
  final bytes = _canonical({'before': before, 'current': current});
  if (file.existsSync()) {
    _require(file.readAsStringSync() == bytes,
        'non-deterministic observation $name');
  } else {
    file.writeAsStringSync(bytes);
  }
}

void recordReferenceObservation(
    String name, String retainedBytes, Map currentSources) {
  verifyRetainedBytes(name, retainedBytes);
  final retained = jsonDecode(retainedBytes) as Map;
  recordProvenanceObservation(
      name, retained, _withBindings(retained, currentSources));
}
