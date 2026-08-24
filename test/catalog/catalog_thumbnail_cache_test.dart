import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await CatalogThumbnailCache.clearForTesting();
  });

  group('CatalogThumbnailCache', () {
    test('renderSignature is deterministic per input', () {
      final a = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 2,
        width: 256,
        height: 256,
      );
      final b = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 2,
        width: 256,
        height: 256,
      );
      expect(a, b);
      expect(a.contains('core.mandelbrot'), isTrue);
    });

    test('renderSignature changes when render caps change', () {
      final lowIter = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 18,
        maxColorCount: 16,
        paletteIndex: 2,
        width: 256,
        height: 256,
      );
      final highIter = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 2,
        width: 256,
        height: 256,
      );
      expect(lowIter, isNot(highIter));
    });

    test('renderSignature changes per catalogId/palette', () {
      final a = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 3,
        width: 256,
        height: 256,
      );
      final b = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.julia',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 3,
        width: 256,
        height: 256,
      );
      expect(a, isNot(b));
    });

    test('memory store makes bytes available in-session', () async {
      final sig = CatalogThumbnailCache.renderSignature(
        catalogId: 'core.mandelbrot',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 0,
        width: 256,
        height: 256,
      );
      expect(CatalogThumbnailCache.inMemory(sig), isNull);

      await CatalogThumbnailCache.store(sig, Uint8List.fromList([1, 2, 3]));

      final bytes = CatalogThumbnailCache.inMemory(sig);
      expect(bytes, isNotNull);
      expect(bytes, [1, 2, 3]);
    });

    test('signature key isolates entries from each other', () async {
      final a = CatalogThumbnailCache.renderSignature(
        catalogId: 'a',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 0,
        width: 256,
        height: 256,
      );
      final b = CatalogThumbnailCache.renderSignature(
        catalogId: 'b',
        maxIterations: 32,
        maxColorCount: 16,
        paletteIndex: 0,
        width: 256,
        height: 256,
      );
      await CatalogThumbnailCache.store(a, Uint8List.fromList([9]));
      expect(CatalogThumbnailCache.inMemory(b), isNull);
    });

    test('diskPruneVictims keeps the newest entries under the cap', () {
      final base = DateTime(2026, 1, 1);
      final entries = [
        for (var i = 0; i < 5; i++)
          DiskEntry('/cache/thumb_$i.png', base.add(Duration(hours: i))),
      ];

      final victims = CatalogThumbnailCache.diskPruneVictims(entries, cap: 3);

      expect(victims.map((e) => e.path), [
        '/cache/thumb_0.png',
        '/cache/thumb_1.png',
      ]);
    });

    test('diskPruneVictims returns nothing at or under the cap', () {
      final now = DateTime(2026, 1, 1);
      final entries = [
        DiskEntry('/cache/a.png', now),
        DiskEntry('/cache/b.png', now.add(const Duration(minutes: 1))),
      ];

      expect(CatalogThumbnailCache.diskPruneVictims(entries, cap: 2), isEmpty);
      expect(CatalogThumbnailCache.diskPruneVictims(entries, cap: 5), isEmpty);
    });

    test('diskPruneVictims breaks ties deterministically by path', () {
      final now = DateTime(2026, 1, 1);
      final entries = [
        DiskEntry('/cache/b.png', now),
        DiskEntry('/cache/a.png', now),
      ];

      final victims = CatalogThumbnailCache.diskPruneVictims(entries, cap: 1);

      expect(victims.single.path, '/cache/a.png');
    });
  });
}
