import 'dart:async';
import 'dart:isolate';

import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_worker.dart';
import 'package:flutter_test/flutter_test.dart';

int _doubleInput(int input) => input * 2;

void main() {
  group('ExportCoordinator', () {
    test('allows only one export operation at a time and releases it',
        () async {
      final coordinator = ExportCoordinator();
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();

      final first = coordinator.run(ExportKind.image, (token) async {
        firstStarted.complete();
        await releaseFirst.future;
        return 1;
      });
      await firstStarted.future;

      expect(coordinator.activeKind, ExportKind.image);
      await expectLater(
        coordinator.run(ExportKind.video, (_) async => 2),
        throwsA(isA<ExportBusyException>()),
      );

      releaseFirst.complete();
      expect(await first, 1);
      expect(coordinator.activeKind, isNull);
      expect(await coordinator.run(ExportKind.video, (_) async => 2), 2);
    });

    test('cancels the active token and always releases the operation',
        () async {
      final coordinator = ExportCoordinator();
      final started = Completer<void>();

      final result = coordinator.run(ExportKind.batch, (token) async {
        started.complete();
        await token.whenCancelled;
        token.throwIfCancelled();
      });
      await started.future;

      expect(coordinator.cancelActive(), isTrue);
      await expectLater(result, throwsA(isA<ExportCancelledException>()));
      expect(coordinator.activeKind, isNull);
      expect(coordinator.cancelActive(), isFalse);
    });

    test('reuses the authoritative lease only for nested owner work', () async {
      final coordinator = ExportCoordinator();
      final nestedStarted = Completer<void>();
      final releaseNested = Completer<void>();

      final owned = coordinator.run(ExportKind.image, (outerToken) async {
        return coordinator.run(ExportKind.image, (innerToken) async {
          expect(identical(innerToken, outerToken), isTrue);
          nestedStarted.complete();
          await releaseNested.future;
          return 7;
        });
      });
      await nestedStarted.future;

      await expectLater(
        coordinator.run(ExportKind.video, (_) async => 2),
        throwsA(isA<ExportBusyException>()),
      );

      releaseNested.complete();
      expect(await owned, 7);
      expect(coordinator.isBusy, isFalse);
    });

    test('rejects a nested export of a different kind', () async {
      final coordinator = ExportCoordinator();

      await coordinator.run(ExportKind.image, (_) async {
        await expectLater(
          coordinator.run(ExportKind.video, (_) async => 2),
          throwsA(isA<ExportBusyException>()),
        );
      });

      expect(coordinator.isBusy, isFalse);
    });
  });

  group('IsolateExportWorker', () {
    test('runs work on a worker isolate', () async {
      final mainIsolate = Isolate.current.debugName;
      final workerName = await const IsolateExportWorker().run(
        () => Isolate.current.debugName,
      );

      expect(workerName, isNot(mainIsolate));
      expect(workerName, contains('export-worker'));
    });

    test('runs a top-level function with an explicit sendable input', () async {
      final value = await const IsolateExportWorker().runWithInput(
        _doubleInput,
        21,
      );
      expect(value, 42);
    });

    test('kills in-flight work when its token is cancelled', () async {
      final token = ExportCancellationToken();
      final started = Completer<void>();

      final work = const IsolateExportWorker().run(() async {
        await Future<void>.delayed(const Duration(seconds: 30));
        return 1;
      }, token: token, onSpawned: started.complete);
      await started.future;
      token.cancel();

      await expectLater(work, throwsA(isA<ExportCancelledException>()));
    });
  });
}
