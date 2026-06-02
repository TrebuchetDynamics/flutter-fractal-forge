import 'dart:async';

import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_tile_worker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpuTileWorker', () {
    test('propagates tile render failures instead of hanging', () async {
      final worker = await CpuTileWorker.spawn();
      addTearDown(worker.dispose);

      final future = worker.renderTile(_tileRequest(x0: 3, w: 2)).timeout(
            const Duration(seconds: 1),
            onTimeout: () => throw TimeoutException(
              'CpuTileWorker.renderTile did not reply to an invalid tile',
            ),
          );

      await expectLater(
        future,
        throwsA(
          isA<CpuTileWorkerException>().having(
            (error) => error.message,
            'message',
            contains('within the full viewport'),
          ),
        ),
      );
    });

    test('rejects jobs submitted after disposal instead of waiting forever',
        () async {
      final worker = await CpuTileWorker.spawn();
      worker.dispose();

      final future = worker.renderTile(_tileRequest()).timeout(
            const Duration(milliseconds: 200),
            onTimeout: () => throw TimeoutException(
              'CpuTileWorker.renderTile waited on a disposed worker',
            ),
          );

      await expectLater(future, _throwsDisposedWorkerStateError);
    });

    test('rejects pending jobs when disposal races an in-flight tile',
        () async {
      final worker = await CpuTileWorker.spawn();

      final future = worker.renderTile(_tileRequest()).timeout(
            const Duration(milliseconds: 200),
            onTimeout: () => throw TimeoutException(
              'CpuTileWorker.renderTile waited after disposal closed a job',
            ),
          );
      final expectation = expectLater(future, _throwsDisposedWorkerStateError);
      worker.dispose();

      await expectation;
    });
  });
}

Matcher get _throwsDisposedWorkerStateError => throwsA(
      isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('disposed'),
      ),
    );

CpuTileRenderRequest _tileRequest({
  int fullWidth = 4,
  int fullHeight = 4,
  int x0 = 0,
  int y0 = 0,
  int w = 1,
  int h = 1,
}) {
  return CpuTileRenderRequest(
    moduleId: 'mandelbrot',
    panX: 0.0,
    panY: 0.0,
    zoom: 1.0,
    iterations: 32,
    bailout: 4.0,
    juliaCX: -0.8,
    juliaCY: 0.156,
    fullWidth: fullWidth,
    fullHeight: fullHeight,
    x0: x0,
    y0: y0,
    w: w,
    h: h,
    sampleCount: 1,
  );
}
