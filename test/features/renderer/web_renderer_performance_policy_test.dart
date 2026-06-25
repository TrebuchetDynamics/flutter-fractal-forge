import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web GPU iterations are capped below desktop quality ceiling', () {
    expect(
      WebRendererPerformancePolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: true,
        playwrightSmoke: false,
        playwrightSmokeMaxGpuIterations: 10,
      ),
      WebRendererPerformancePolicy.webMaxGpuIterations,
    );
  });

  test('desktop GPU iterations are not capped by web policy', () {
    expect(
      WebRendererPerformancePolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: false,
        playwrightSmoke: false,
        playwrightSmokeMaxGpuIterations: 10,
      ),
      500,
    );
  });

  test('playwright smoke cap still wins over web cap', () {
    expect(
      WebRendererPerformancePolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: true,
        playwrightSmoke: true,
        playwrightSmokeMaxGpuIterations: 12,
      ),
      12,
    );
  });
}
