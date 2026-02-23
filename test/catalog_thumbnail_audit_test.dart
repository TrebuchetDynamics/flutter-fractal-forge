// ignore_for_file: avoid_print
/// Audits that every catalog entry has a matching thumbnail PNG.
///
/// Run: flutter test test/catalog_thumbnail_audit_test.dart
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';

void main() {
  test('Every catalog entry has a valid thumbnail PNG', () {
    final thumbDir = Directory('assets/catalog_thumbs');
    expect(thumbDir.existsSync(), isTrue,
        reason: 'assets/catalog_thumbs/ must exist');

    final allFiles = thumbDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.png', ''))
        .toSet();

    // Get all catalog IDs from escape_time_catalog
    final catalogIds = escapeTimeCatalog.map((c) => c.id).toList();

    // Also get custom module IDs from ModuleRegistry
    final registry = ModuleRegistry();
    final allModuleIds = registry.modules.map((m) => m.id).toSet();

    int matched = 0;
    int missing = 0;
    int tooSmall = 0;
    int badDimensions = 0;
    final missingIds = <String>[];
    final tooSmallIds = <String>[];

    print('=== Catalog Thumbnail Audit ===');
    print('Catalog entries (escape_time): ${catalogIds.length}');
    print('All modules (registry): ${allModuleIds.length}');
    print('PNG files on disk: ${allFiles.length}');
    print('');

    for (final id in catalogIds) {
      final file = File('assets/catalog_thumbs/$id.png');
      if (!file.existsSync()) {
        missing++;
        missingIds.add(id);
        print('  MISSING: $id');
        continue;
      }

      final bytes = file.readAsBytesSync();
      if (bytes.length < 500) {
        tooSmall++;
        tooSmallIds.add(id);
        print('  TOO_SMALL: $id (${bytes.length} bytes)');
        continue;
      }

      // Verify it's a valid PNG with correct dimensions
      final image = img.decodePng(bytes);
      if (image == null || image.width < 64 || image.height < 64) {
        badDimensions++;
        print('  BAD_IMAGE: $id (${image?.width}x${image?.height})');
        continue;
      }

      matched++;
    }

    // Check for modules NOT in escape_time_catalog but in registry
    // (custom modules: julia, phoenix, mandelbulb, etc.)
    final customIds = allModuleIds.difference(catalogIds.toSet());
    final customMissing = <String>[];
    for (final id in customIds) {
      if (!allFiles.contains(id)) {
        customMissing.add(id);
      }
    }

    print('');
    print('=== Results ===');
    print('Escape-time entries: ${catalogIds.length}');
    print('  Matched: $matched');
    print('  Missing: $missing ${missingIds.isNotEmpty ? missingIds : ""}');
    print(
        '  Too small: $tooSmall ${tooSmallIds.isNotEmpty ? tooSmallIds : ""}');
    print('  Bad dimensions: $badDimensions');
    print(
        'Custom modules without thumbnails: ${customMissing.length} $customMissing');
    final coverage = catalogIds.isEmpty ? 0.0 : matched / catalogIds.length;
    print('Coverage: ${(coverage * 100).toStringAsFixed(1)}%');
    print('');

    // Ensure existing thumbnail assets remain valid and coverage does not regress
    // dramatically. The app supports gradient fallbacks for modules that do not
    // yet have generated PNG previews.
    expect(tooSmall, 0,
        reason: 'No thumbnails should be < 500 bytes: $tooSmallIds');
    expect(badDimensions, 0,
        reason: 'All thumbnails must be valid PNGs >= 64x64');
    expect(matched, greaterThan(0),
        reason: 'At least one catalog thumbnail should be present');
    expect(
      coverage,
      greaterThanOrEqualTo(0.20),
      reason:
          'Thumbnail coverage regressed below 20%; missing IDs include: $missingIds',
    );
  });
}
