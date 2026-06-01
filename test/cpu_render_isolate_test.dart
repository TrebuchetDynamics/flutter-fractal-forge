import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';

void main() {
  group('CPU render viewport mapping', () {
    test('keeps opposite edge pixel centers symmetric around pan', () {
      final left = cpuViewportCoordinateForSample(
        panX: -0.5,
        panY: 0.25,
        zoom: 3.0,
        fullWidth: 4,
        fullHeight: 2,
        x: 0,
        y: 0,
        sampleOffsetX: 0.5,
        sampleOffsetY: 0.5,
      );
      final right = cpuViewportCoordinateForSample(
        panX: -0.5,
        panY: 0.25,
        zoom: 3.0,
        fullWidth: 4,
        fullHeight: 2,
        x: 3,
        y: 1,
        sampleOffsetX: 0.5,
        sampleOffsetY: 0.5,
      );

      expect(left.x + right.x, closeTo(-1.0, 1e-12));
      expect(left.y + right.y, closeTo(0.5, 1e-12));
    });

    test('rejects tile rectangles outside the full viewport before sampling', () {
      const request = CpuTileRenderRequest(
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
      );

      expect(
        () => renderCpuTileInIsolate(request),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('within the full viewport'),
          ),
        ),
      );
    });

    test('maps a one-pixel frame to the requested pan center', () {
      const request = CpuRenderRequest(
        moduleId: 'mandelbrot',
        panX: -0.5,
        panY: 0.25,
        zoom: 3.0,
        iterations: 32,
        bailout: 4.0,
        juliaCX: -0.8,
        juliaCY: 0.156,
        width: 1,
        height: 1,
        sampleCount: 1,
      );

      final frame = renderCpuFrameInIsolate(request);
      final expected = cpuFormulaForModuleId(request.moduleId)(
        request.panX,
        request.panY,
        request.iterations,
        request.bailout,
        Vector2(request.juliaCX, request.juliaCY),
      );

      expect(frame.rgba, hasLength(4));
      expect(frame.rgba[0], expected.$1.clamp(0, 255).round());
      expect(frame.rgba[1], expected.$2.clamp(0, 255).round());
      expect(frame.rgba[2], expected.$3.clamp(0, 255).round());
      expect(frame.rgba[3], 255);
    });
  });
}
