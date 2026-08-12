/// Every-Fractal Programmatic Smoke
///
/// Reads `docs/catalog/fractal_registry.yaml` (1610 tier entries, 367
/// `tier: implemented`), filters to the `tier: implemented` entries, and
/// verifies:
///   1. Each entry has the required metadata (id, name, shader, formula_hash).
///   2. The app launches and the catalog surface renders without exceptions.
///
///   The exhaustive per-fractal viewer walkthrough now lives in
///   `test/features/viewer/every_module_viewer_walk_test.dart` (fast widget
///   sweep over the live ModuleRegistry, no device needed).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

/// Candidate paths the registry might live at, depending on how the test is
/// invoked (flutter test from project root vs. direct dart execution).
const List<String> _registryCandidates = <String>[
  'docs/catalog/fractal_registry.yaml',
  '../docs/catalog/fractal_registry.yaml',
];

List<Map<String, dynamic>> _loadRegistryImplementedEntries() {
  File? registryFile;
  for (final path in _registryCandidates) {
    final f = File(path);
    if (f.existsSync()) {
      registryFile = f;
      break;
    }
  }
  if (registryFile == null) {
    throw StateError(
      'Could not locate fractal_registry.yaml at any of: '
      '${_registryCandidates.join(", ")}',
    );
  }

  final registryText = registryFile.readAsStringSync();
  final registry = loadYaml(registryText) as YamlMap;
  final entries = (registry['fractals'] as YamlList).cast<YamlMap>();

  return entries
      .where((e) => e['tier'] == 'implemented')
      .map<Map<String, dynamic>>((e) {
    final map = <String, dynamic>{};
    for (final key in e.keys) {
      map['$key'] = e[key];
    }
    return map;
  }).toList();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Every fractal — programmatic smoke', () {
    late List<Map<String, dynamic>> implementedEntries;

    setUpAll(() async {
      // Android integration tests run inside the app sandbox, which cannot
      // read repository documentation files.
      if (Platform.isAndroid) return;
      implementedEntries = _loadRegistryImplementedEntries();
      debugPrint(
        'Loaded ${implementedEntries.length} tier:implemented entries from registry',
      );
      expect(
        implementedEntries.length,
        greaterThanOrEqualTo(350),
        reason: 'implemented-tier entries dropped below 350 — regression?',
      );
    });

    testWidgets('All implemented-tier entries have required metadata',
        (tester) async {
      // Metadata-only check. Fast; doesn't render anything.
      final errors = <String>[];
      final seenIds = <String>{};

      for (final entry in implementedEntries) {
        final id = (entry['id'] ?? '').toString();
        if (id.isEmpty) {
          errors.add('entry missing id: $entry');
          continue;
        }
        if (!seenIds.add(id)) {
          errors.add('duplicate id: $id');
        }

        final name = (entry['name'] ?? '').toString();
        if (name.isEmpty) errors.add('$id: missing name');

        final shader = (entry['shader'] ?? '').toString();
        if (shader.isEmpty) errors.add('$id: missing shader');

        final formulaHash = (entry['formula_hash'] ?? '').toString();
        if (!formulaHash.startsWith('sha256:')) {
          errors.add('$id: formula_hash missing or malformed: "$formulaHash"');
        }

        final category = (entry['category'] ?? '').toString();
        if (category.isEmpty) errors.add('$id: missing category');

        if (entry['implemented'] != true) {
          errors.add('$id: tier=implemented but implemented != true');
        }
      }

      if (errors.isNotEmpty) {
        debugPrint('Metadata errors (${errors.length}):');
        for (final e in errors.take(50)) {
          debugPrint('  - $e');
        }
      }
      expect(errors, isEmpty,
          reason: 'found ${errors.length} metadata errors across '
              '${implementedEntries.length} implemented entries');
    }, skip: Platform.isAndroid);

    testWidgets('Every implemented entry declares a non-empty shader path',
        (tester) async {
      // Stricter: shader paths must look like real relative asset paths and
      // live under shaders/ so that pubspec.yaml can reach them.
      final bad = <String>[];
      for (final entry in implementedEntries) {
        final shader = (entry['shader'] ?? '').toString();
        if (!shader.startsWith('shaders/') || !shader.endsWith('.frag')) {
          bad.add('${entry['id']}: "$shader"');
        }
      }
      if (bad.isNotEmpty) {
        debugPrint('Shader path violations (${bad.length}):');
        for (final b in bad.take(30)) {
          debugPrint('  - $b');
        }
      }
      expect(bad, isEmpty,
          reason:
              'shader paths must start with "shaders/" and end with ".frag"');
    }, skip: Platform.isAndroid);

    testWidgets('Catalog screen renders without throwing exceptions',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final presetStore = await PresetStore.create();
      final accessibilityService = await AccessibilityService.create();
      final rendererSettingsService = await RendererSettingsService.create();

      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // Any thrown exception in widget tree is surfaced here.
      expect(tester.takeException(), isNull,
          reason: 'catalog boot threw an exception');
      // The catalog must expose real module cards after boot.
      expect(catalogModuleCards(), findsWidgets,
          reason: 'catalog module cards missing — UI regression');
    });

    testWidgets(
      'Exhaustive viewer walkthrough lives in the widget-test suite',
      (tester) async {
        // The full every-module viewer sweep runs as a fast widget test:
        //   test/features/viewer/every_module_viewer_walk_test.dart
        // It opens every ModuleRegistry module (escape-time, 3D, custom,
        // diagnostics) in the real FractalViewerScreen tree and asserts no
        // exception + the stable Key('fractalViewerRoot').
        expect(true, isTrue, reason: 'see every_module_viewer_walk_test.dart');
      },
    );
  });
}
