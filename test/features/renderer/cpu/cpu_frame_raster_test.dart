import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  group('CPU frame raster contracts', () {
    test('direct and isolate full-frame renders share the same bytes',
        () async {
      final direct = await renderCpuFrame(
        moduleId: 'julia',
        viewPan: Vector2(-0.25, 0.1),
        viewZoom: 2.0,
        iterations: 40,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 3,
        height: 2,
        sampleCount: 4,
      );

      const isolateRequest = CpuRenderRequest(
        moduleId: 'julia',
        panX: -0.25,
        panY: 0.1,
        zoom: 2.0,
        iterations: 40,
        bailout: 4.0,
        juliaCX: -0.8,
        juliaCY: 0.156,
        width: 3,
        height: 2,
        sampleCount: 4,
      );
      final isolate = renderCpuFrameInIsolate(isolateRequest);

      expect(direct.width, isolate.width);
      expect(direct.height, isolate.height);
      expect(direct.rgba, isolate.rgba);
    });

    test('direct full-frame render rejects non-positive dimensions', () async {
      await expectLater(
        renderCpuFrame(
          moduleId: 'mandelbrot',
          viewPan: Vector2.zero(),
          viewZoom: 1.0,
          iterations: 32,
          bailout: 4.0,
          juliaC: Vector2(-0.8, 0.156),
          width: 0,
          height: 4,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'full viewport',
          ),
        ),
      );
    });
  });
}
