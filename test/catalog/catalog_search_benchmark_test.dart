import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Run with --dart-define=CATALOG_SEARCH_BENCHMARK=true. Keep timing
  // thresholds out of CI: the result depends on the machine and build mode.
  test('catalog search benchmark', () {
    final entries = CatalogRepository.fromRegistry(ModuleRegistry()).entries;
    final l10n = AppLocalizationsEn();
    for (final query in ['color', 'julia', '3d', 'no-match']) {
      final samples = <int>[];
      var matches = 0;
      for (var round = 0; round < 9; round++) {
        final watch = Stopwatch()..start();
        final result = CatalogFilter.apply(
          entries: entries,
          criteria: CatalogFilterCriteria(query: query),
          l10n: l10n,
        );
        watch.stop();
        matches = result.filteredEntries.length;
        if (round >= 2) samples.add(watch.elapsedMicroseconds);
      }
      samples.sort();
      // ignore: avoid_print
      print('CATALOG_BENCH query=$query entries=${entries.length} '
          'matches=$matches median_us=${samples[3]}');
    }
  }, skip: !const bool.fromEnvironment('CATALOG_SEARCH_BENCHMARK'));
}
