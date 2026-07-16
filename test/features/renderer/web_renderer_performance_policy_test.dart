import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web GPU iterations are capped below desktop quality ceiling', () {
    expect(
      GpuIterationPolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: true,
        isMobile: false,
        playwrightSmoke: false,
        playwrightSmokeMaxGpuIterations: 10,
      ),
      GpuIterationPolicy.webMaxGpuIterations,
    );
  });

  test('mobile GPU iterations use the safe ceiling', () {
    expect(
      GpuIterationPolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: false,
        isMobile: true,
        playwrightSmoke: false,
        playwrightSmokeMaxGpuIterations: 10,
      ),
      GpuIterationPolicy.mobileMaxGpuIterations,
    );
  });

  test('desktop GPU iterations are not capped', () {
    expect(
      GpuIterationPolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: false,
        isMobile: false,
        playwrightSmoke: false,
        playwrightSmokeMaxGpuIterations: 10,
      ),
      500,
    );
  });

  test('playwright smoke cap still wins over platform caps', () {
    expect(
      GpuIterationPolicy.effectiveGpuIterations(
        scaledIterations: 500,
        isWeb: true,
        isMobile: false,
        playwrightSmoke: true,
        playwrightSmokeMaxGpuIterations: 12,
      ),
      12,
    );
  });
}
