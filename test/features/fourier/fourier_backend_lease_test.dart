import 'dart:async';

import 'package:flutter_fractals/features/fourier/services/fourier_analysis_controller.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_backend_lease.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeBackend implements FourierAnalysisBackend {
  int closeCount = 0;

  @override
  Future<FourierWorkerResult> analyze(FourierWorkerRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> close() async {
    closeCount++;
  }
}

void main() {
  test('on-off-on closes stale spawn and returns only current backend',
      () async {
    final lease = FourierBackendLease();
    final firstSpawn = Completer<FourierAnalysisBackend>();
    final secondSpawn = Completer<FourierAnalysisBackend>();

    final firstGeneration = lease.begin();
    final firstAcquisition = lease.acquire(
      generation: firstGeneration,
      factory: () => firstSpawn.future,
      isActive: () => true,
    );

    lease.invalidate(); // off
    final secondGeneration = lease.begin(); // on again
    final secondAcquisition = lease.acquire(
      generation: secondGeneration,
      factory: () => secondSpawn.future,
      isActive: () => true,
    );

    final stale = _FakeBackend();
    firstSpawn.complete(stale);
    expect(await firstAcquisition, isNull);
    expect(stale.closeCount, 1);

    final current = _FakeBackend();
    secondSpawn.complete(current);
    expect(await secondAcquisition, same(current));
    expect(current.closeCount, 0);
  });

  test('inactive route closes a backend even when generation is current',
      () async {
    final lease = FourierBackendLease();
    final generation = lease.begin();
    final backend = _FakeBackend();

    final acquired = await lease.acquire(
      generation: generation,
      factory: () async => backend,
      isActive: () => false,
    );

    expect(acquired, isNull);
    expect(backend.closeCount, 1);
  });
}
