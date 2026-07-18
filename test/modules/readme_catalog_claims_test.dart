import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Anchors the public copy in README.md (and the store listing) to the code.
///
/// If these fail, the registry or palette set changed size: update the
/// numbers in README.md and docs/store_listing/ together with this test.
void main() {
  test('public production fractal counts match the registry', () {
    final modules = ModuleRegistry().modules;
    final production = modules
        .where((m) => !m.shaderAsset.startsWith('shaders/diagnostic/'))
        .length;
    final diagnostics = modules.length - production;

    expect(production, 977,
        reason: 'README.md advertises 977 production fractals');
    expect(diagnostics, 7,
        reason: 'README.md says debug/test builds add 7 diagnostic modules');

    expect(
      File('README.md').readAsStringSync(),
      contains('$production production fractals'),
    );

    final listing = jsonDecode(
      File('docs/play-store-localized-listings.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(listing['count'], '$production production fractals');

    final locales = listing['locales'] as Map<String, dynamic>;
    for (final entry in locales.entries) {
      final copy = entry.value as Map<String, dynamic>;
      expect(copy['shortDescription'], contains('$production'),
          reason: '${entry.key} short description has a stale catalog count');
      expect(copy['fullDescription'], contains('$production'),
          reason: '${entry.key} full description has a stale catalog count');
    }
  });

  test('README color scheme count is backed by the palette set', () {
    expect(CommonFractalParams.paletteCount, greaterThanOrEqualTo(60),
        reason: 'README.md advertises 60+ color schemes');
  });
}
