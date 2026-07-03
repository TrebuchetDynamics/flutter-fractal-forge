import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/catalog_id_collisions.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';

/// Catalog ID integrity tests (P0 #4).
///
/// These tests act as a lock on the catalog — any accidental rename,
/// removal, or duplication of a catalog ID will be caught here.
///
/// ## Expected counts (update when catalog intentionally grows)
///
/// - Escape-time catalog raw unique IDs       : 501
/// - Raymarched-3D catalog unique IDs         :  10
/// - Custom hand-built modules                :   7
///   (julia, julia_dual, phoenix, nova, mandelbulb, mandelbox,
///    hydrogen_orbital)
/// - Total ModuleRegistry modules (debug/test) : 981
/// - Production fractals excluding diagnostics     : 974
///
/// The debug/test registry includes 7 diagnostic shader modules; public copy
/// should use 974 production fractals. The "196 GPU shaders" figure in TODO.md refers to fragment shader
/// assets compiled at build time; it predates the full catalog expansion.
void main() {
  // ---------------------------------------------------------------------------
  // 1. Escape-time catalog — raw entries
  // ---------------------------------------------------------------------------
  group('EscapeTimeConfig catalog entries', () {
    late final List<EscapeTimeConfig> catalog;

    setUpAll(() {
      catalog = escapeTimeCatalog;
    });

    test('total entry count is 501', () {
      expect(catalog.length, 501,
          reason: 'Update this constant when entries are intentionally '
              'added to or removed from escape_time_catalog.dart.');
    });

    test('all IDs match pattern: lowercase alphanumeric + underscores', () {
      final pattern = RegExp(r'^[a-z0-9_]+$');
      final bad = catalog
          .map((c) => c.id)
          .where((id) => !pattern.hasMatch(id))
          .toList();
      expect(bad, isEmpty,
          reason: 'IDs must be lowercase alphanumeric + underscores. '
              'Bad IDs: $bad');
    });

    test('all IDs are unique before registry de-duplication', () {
      final collisions = findCatalogIdCollisions(catalog, (c) => c.id);
      final collisionSummary = collisions
          .map((c) => '${c.id}@${c.indexes.join(',')}')
          .toList(growable: false);

      expect(
        collisionSummary,
        isEmpty,
        reason: 'Duplicate raw catalog IDs are silently dropped before '
            'ModuleRegistry exposes modules.',
      );
    });

    test('no catalog entry has an empty name', () {
      final empty = catalog.where((c) => c.name.trim().isEmpty).toList();
      expect(empty.map((c) => c.id).toList(), isEmpty,
          reason: 'Every catalog entry must have a non-empty name.');
    });

    test('no catalog entry has an empty shader asset path', () {
      final empty = catalog.where((c) => c.shaderAsset.trim().isEmpty).toList();
      expect(empty.map((c) => c.id).toList(), isEmpty,
          reason: 'Every catalog entry must declare a shaderAsset path.');
    });

    // Snapshot test: any rename/removal/addition will fail here.
    // Update this list when intentionally changing catalog IDs.
    test('snapshot — first 20 catalog IDs are stable', () {
      final expected = [
        'mandelbrot',
        'burning_ship',
        'tricorn',
        'celtic',
        'buffalo',
        'multibrot3',
        'nova_julia',
        'fatou',
        'gamma_fractal',
        'perpendicular_mandelbrot',
        'lambda',
        'magnet_type_1',
        'magnet_type_2',
        'magnet_type_3',
        'power_sum',
        'cactus',
        'astroid',
        'deltoid',
        'eisenstein',
        'druid',
      ];
      final actual = catalog.take(20).map((c) => c.id).toList();
      expect(actual, expected,
          reason: 'First-20 catalog IDs changed. '
              'If intentional, update this snapshot.');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. ModuleRegistry — built registry (debug/test includes diagnostics)
  // ---------------------------------------------------------------------------
  group('ModuleRegistry integrity', () {
    late final ModuleRegistry registry;

    setUpAll(() {
      registry = ModuleRegistry();
    });

    test('total module count is 981 in debug/test', () {
      // Debug/test builds include 7 diagnostic modules. Public docs count
      // production fractals as 974 after excluding those diagnostics.
      expect(registry.modules.length, 981,
          reason: 'Update this constant when modules are intentionally '
              'added to or removed from the de-duplicated registry.');
    });

    test('all module IDs are unique (no duplicates)', () {
      final ids = registry.modules.map((m) => m.id).toList();
      final seen = <String>{};
      final dupes = <String>[];
      for (final id in ids) {
        if (!seen.add(id)) dupes.add(id);
      }
      expect(dupes, isEmpty,
          reason: 'Duplicate module IDs detected: $dupes. '
              'The registry deduplicates, but duplicates in the raw catalog '
              'waste entries.');
    });

    test('all module IDs match pattern: lowercase alphanumeric + underscores',
        () {
      final pattern = RegExp(r'^[a-z0-9_]+$');
      final bad = registry.modules
          .map((m) => m.id)
          .where((id) => !pattern.hasMatch(id))
          .toList();
      expect(bad, isEmpty, reason: 'Non-conforming module IDs: $bad');
    });

    test('no module has an empty shader asset path', () {
      final empty = registry.modules
          .where((m) => m.shaderAsset.trim().isEmpty)
          .map((m) => m.id)
          .toList();
      expect(empty, isEmpty,
          reason: 'Every module must declare a non-empty shaderAsset. '
              'Missing: $empty');
    });

    test('byId lookup succeeds for mandelbrot', () {
      expect(() => registry.byId('mandelbrot'), returnsNormally);
      expect(registry.byId('mandelbrot').id, 'mandelbrot');
    });

    test('keeps one configurable elementary CA instead of promoted rule spam',
        () {
      final elementaryRules = registry.modules
          .where((m) => m.id.contains('elementary_ca_rule'))
          .map((m) => m.id)
          .toList();

      expect(elementaryRules, isEmpty);
      expect(
          registry.byId('wolfram_rule30').defaultPreset.params['rule'], 30.0);
    });

    test('byId lookup succeeds for all custom hand-built modules', () {
      const customIds = [
        'julia',
        'julia_dual',
        'phoenix',
        'nova',
        'mandelbulb',
        'mandelbox',
        'hydrogen_orbital',
      ];
      for (final id in customIds) {
        expect(
          () => registry.byId(id),
          returnsNormally,
          reason: 'Custom module "$id" not found in registry.',
        );
      }
    });

    // Snapshot of known-stable IDs. Removing or renaming any of these will
    // fail this test, prompting an intentional update.
    test('snapshot — known stable module IDs are present', () {
      const knownIds = [
        'mandelbrot',
        'julia',
        'julia_dual',
        'burning_ship',
        'phoenix',
        'nova',
        'nova_julia',
        'tricorn',
        'celtic',
        'buffalo',
        'multibrot3',
        'mandelbulb',
        'mandelbox',
        'hydrogen_orbital',
        'kifs_menger',
        'kifs_sierpinski_tetra',
        'quaternion_julia_3d',
        'amazing_box',
        'bulbils',
        'hartverdrahtet',
        'tglad_formula',
        'seeds_ca',
        'maze_ca',
        'cyclic_ca',
        'replicator_ca',
        'hodgepodge_machine',
      ];
      final registryIds = registry.modules.map((m) => m.id).toSet();
      final missing = knownIds.where((id) => !registryIds.contains(id));
      expect(missing, isEmpty,
          reason: 'Previously-present module IDs are missing: $missing. '
              'If intentional, update this snapshot.');
    });
  });
}
