import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_render_gate.dart';

void main() {
  tearDown(CatalogThumbnailRenderGate.resetForTesting);

  group('CatalogThumbnailRenderGate', () {
    test('grants up to maxConcurrent slots without queueing', () async {
      expect(CatalogThumbnailRenderGate.maxConcurrent, greaterThan(0));

      final futures = List.generate(
        CatalogThumbnailRenderGate.maxConcurrent,
        (_) => CatalogThumbnailRenderGate.acquire(),
      );
      await Future.wait(futures);

      expect(CatalogThumbnailRenderGate.activeForTesting,
          CatalogThumbnailRenderGate.maxConcurrent);
      expect(CatalogThumbnailRenderGate.queuedForTesting, 0);
    });

    test('queues the next acquire beyond the limit', () async {
      for (var i = 0; i < CatalogThumbnailRenderGate.maxConcurrent; i++) {
        await CatalogThumbnailRenderGate.acquire();
      }

      var queuedResolved = false;
      final queued = CatalogThumbnailRenderGate.acquire().then((_) {
        queuedResolved = true;
      });

      expect(CatalogThumbnailRenderGate.queuedForTesting, 1);
      expect(queuedResolved, isFalse);

      CatalogThumbnailRenderGate.release();
      await queued;

      expect(queuedResolved, isTrue);
      // Slot handover: the released slot went straight to the waiter.
      expect(CatalogThumbnailRenderGate.activeForTesting,
          CatalogThumbnailRenderGate.maxConcurrent);
      expect(CatalogThumbnailRenderGate.queuedForTesting, 0);
    });

    test('release with no waiters frees the slot for a new acquire', () async {
      await CatalogThumbnailRenderGate.acquire();
      CatalogThumbnailRenderGate.release();

      expect(CatalogThumbnailRenderGate.activeForTesting, 0);

      await CatalogThumbnailRenderGate.acquire();
      expect(CatalogThumbnailRenderGate.activeForTesting, 1);
      CatalogThumbnailRenderGate.release();
    });

    test('a queued waiter that dies before resolution passes its slot on',
        () async {
      for (var i = 0; i < CatalogThumbnailRenderGate.maxConcurrent; i++) {
        await CatalogThumbnailRenderGate.acquire();
      }

      // First waiter gives up (unmounted) before its slot arrives.
      var firstResolved = false;
      CatalogThumbnailRenderGate.acquire().then((_) {
        firstResolved = true;
        // The dead holder still releases the handed-over slot.
        CatalogThumbnailRenderGate.release();
      });

      var secondResolved = false;
      final second = CatalogThumbnailRenderGate.acquire().then((_) {
        secondResolved = true;
      });

      expect(CatalogThumbnailRenderGate.queuedForTesting, 2);

      // A live renderer finishes; its slot is handed to the dead waiter,
      // which passes it straight on to the second waiter.
      CatalogThumbnailRenderGate.release();
      await second;

      expect(firstResolved, isTrue);
      expect(secondResolved, isTrue);
      expect(CatalogThumbnailRenderGate.queuedForTesting, 0);
    });

    test('resetForTesting drains waiters and clears the counter', () async {
      for (var i = 0; i < CatalogThumbnailRenderGate.maxConcurrent; i++) {
        await CatalogThumbnailRenderGate.acquire();
      }
      final queued = CatalogThumbnailRenderGate.acquire();

      CatalogThumbnailRenderGate.resetForTesting();

      await queued;
      expect(CatalogThumbnailRenderGate.activeForTesting, 0);
      expect(CatalogThumbnailRenderGate.queuedForTesting, 0);
    });

    test('acquires resolve in FIFO order', () async {
      await CatalogThumbnailRenderGate.acquire();
      final order = <int>[];
      final futures = <Future<void>>[
        for (var i = 0; i < 3; i++)
          CatalogThumbnailRenderGate.acquire().then((_) => order.add(i)),
      ];

      for (var i = 0; i < 3; i++) {
        CatalogThumbnailRenderGate.release();
        // Let the handover microtask run before the next release.
        await Future<void>.delayed(Duration.zero);
      }
      await Future.wait(futures);

      expect(order, [0, 1, 2]);
    });
  });

  group('CatalogThumbnailCapturePolicy', () {
    test('allows slow Android shader startup before abandoning capture', () {
      expect(
        CatalogThumbnailCapturePolicy.readinessExpired(
          CatalogThumbnailCapturePolicy.readinessTimeout -
              CatalogThumbnailCapturePolicy.retryInterval,
        ),
        isFalse,
      );
      expect(
        CatalogThumbnailCapturePolicy.readinessExpired(
          CatalogThumbnailCapturePolicy.readinessTimeout,
        ),
        isTrue,
      );
      expect(
        CatalogThumbnailCapturePolicy.readinessTimeout,
        greaterThanOrEqualTo(const Duration(seconds: 10)),
      );
    });

    test('allows concurrent Android PNG readbacks to finish', () {
      expect(
        CatalogThumbnailCapturePolicy.readbackTimeout,
        greaterThanOrEqualTo(const Duration(seconds: 5)),
      );
    });
  });
}
