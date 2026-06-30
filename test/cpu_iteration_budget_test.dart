import 'package:flutter_fractals/features/renderer/cpu/cpu_iteration_budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpuIterationBudget', () {
    test('preserves zoom-depth iteration scaling contract', () {
      expect(
        CpuIterationBudget.forZoom(
          baseIterations: 120,
          maxIterations: 500,
          zoom: 1.0,
        ),
        120,
      );
      expect(
        CpuIterationBudget.forZoom(
          baseIterations: 120,
          maxIterations: 500,
          zoom: 4.0,
        ),
        184,
      );
      expect(
        CpuIterationBudget.forZoom(
          baseIterations: 490,
          maxIterations: 500,
          zoom: 4.0,
        ),
        500,
      );
    });

    test('normalizes malformed zoom samples before log/round', () {
      for (final zoom in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
        0.0,
        -2.0,
      ]) {
        expect(
          CpuIterationBudget.normalizeZoom(zoom),
          1.0,
          reason: 'zoom=$zoom',
        );
        expect(
          CpuIterationBudget.forZoom(
            baseIterations: 120,
            maxIterations: 500,
            zoom: zoom,
          ),
          120,
          reason: 'zoom=$zoom',
        );
      }
    });

    test('keeps the minimum iteration floor replayable', () {
      expect(
        CpuIterationBudget.forZoom(
          baseIterations: 1,
          maxIterations: 10,
          zoom: 1.0,
        ),
        CpuIterationBudget.minimumIterations,
      );
    });
  });
}
