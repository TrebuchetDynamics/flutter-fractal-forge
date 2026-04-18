/// Every-Fractal Programmatic Smoke
///
/// Reads `docs/catalog/fractal_registry.yaml` (370 entries), filters to the
/// 357 `tier: implemented` entries, and verifies:
///   1. Each entry has the required metadata (id, name, shader, formula_hash).
///   2. The app launches and the catalog surface renders without exceptions.
///
/// The exhaustive per-fractal viewer walkthrough is scaffolded below as a
/// `skip:`-gated third test. It is currently skipped because navigating from
/// the catalog into 357 viewers end-to-end is slow (~10-30 min) and the
/// viewer does not yet expose a stable testID that works across every
/// category (escape-time, 3D raymarched, IFS, attractors). Remove the
/// `skip:` argument once a stable `Key('fractalViewerRoot')` lands in the
/// viewer's root widget — see docs/PIPELINE_STATE.md §4 gap #4.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

import 'helpers/ui_test_helpers.dart';

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
      implementedEntries = _loadRegistryImplementedEntries();
      debugPrint(
        'Loaded ${implementedEntries.length} tier:implemented entries from registry',
      );
      // Guard rail: the catalog should have grown, not shrunk. Keep this
      // conservative; today it's exactly 357.
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
    });

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
    });

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
      'Exhaustive: every implemented fractal opens in viewer without crash',
      (tester) async {
        // Placeholder for the full traversal. Enable by removing the
        // `skip:` argument below once:
        //   1. The viewer's root widget exposes Key('fractalViewerRoot')
        //      (uniform across escape-time, 3D, IFS, attractors).
        //   2. CI budget permits a ~30-minute test.
        //
        // Skeleton:
        //   for (final entry in implementedEntries) {
        //     await _openCatalog(tester);
        //     await tester.enterText(
        //       find.byKey(const Key('catalogSearchField')),
        //       entry['name'] as String,
        //     );
        //     await tester.pumpAndSettle();
        //     await tester.tap(find.text(entry['name']!).first);
        //     await tester.pumpAndSettle(const Duration(seconds: 5));
        //     expect(tester.takeException(), isNull,
        //         reason: '${entry['id']} threw on open');
        //     expect(find.byKey(const Key('fractalViewerRoot')),
        //         findsOneWidget,
        //         reason: '${entry['id']} did not reach viewer');
        //     Navigator.of(tester.element(find.byType(Scaffold).first))
        //         .pop();
        //     await tester.pumpAndSettle();
        //   }
        fail('This is a skip-gated placeholder; see doc comment.');
      },
      // Enable by flipping to `false` once Key("fractalViewerRoot") is stable
      // across all viewer variants (tracked in docs/PIPELINE_STATE.md §4 gap #4).
      skip: true,
    );
  });
}
