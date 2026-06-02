import 'dart:async';

import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_tile_worker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpuTileWorker', () {
    test('propagates tile render failures instead of hanging', () async {
      final worker = await CpuTileWorker.spawn();
      addTearDown(worker.dispose);

      final future = worker
          .renderTile(
            const CpuTileRenderRequest(
              moduleId: 'mandelbrot',
              panX: 0.0,
              panY: 0.0,
              zoom: 1.0,
              iterations: 32,
              bailout: 4.0,
              juliaCX: -0.8,
              juliaCY: 0.156,
              fullWidth: 4,
              fullHeight: 4,
              x0: 3,
              y0: 0,
              w: 2,
              h: 1,
              sampleCount: 1,
            ),
          )
          .timeout(
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
  });
}
