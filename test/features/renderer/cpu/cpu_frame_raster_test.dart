import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

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

    test('batched slow-mode rows reproduce the full frame exactly', () {
      const width = 7;
      const height = 18;
      const fullRequest = CpuRenderRequest(
        moduleId: 'julia',
        panX: -0.25,
        panY: 0.1,
        zoom: 2.0,
        iterations: 40,
        bailout: 4.0,
        juliaCX: -0.8,
        juliaCY: 0.156,
        width: width,
        height: height,
        sampleCount: 4,
      );
      final full = renderCpuFrameInIsolate(fullRequest).rgba;
      final batched = Uint8List(full.length);

      var row = 0;
      while (row < height) {
        final remainingRows = height - row;
        final tileHeight =
            row == 0 ? 1 : (remainingRows < 8 ? remainingRows : 8);
        final tile = renderCpuTileInIsolate(
          CpuTileRenderRequest(
            moduleId: fullRequest.moduleId,
            panX: fullRequest.panX,
            panY: fullRequest.panY,
            zoom: fullRequest.zoom,
            iterations: fullRequest.iterations,
            bailout: fullRequest.bailout,
            juliaCX: fullRequest.juliaCX,
            juliaCY: fullRequest.juliaCY,
            fullWidth: width,
            fullHeight: height,
            x0: 0,
            y0: row,
            w: width,
            h: tileHeight,
            sampleCount: fullRequest.sampleCount,
          ),
        );
        final offset = row * width * 4;
        batched.setRange(offset, offset + tile.rgba.length, tile.rgba);
        row += tileHeight;
      }

      expect(batched, full);
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
