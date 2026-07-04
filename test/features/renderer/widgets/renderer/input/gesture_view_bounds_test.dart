import 'package:flutter_fractals/core/controllers/input/fractal_view_input_bounds.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/input/gesture_view_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RendererGestureViewBounds', () {
    test('tracks controller hard zoom and pan bounds', () {
      expect(RendererGestureViewBounds.minZoom,
          FractalViewInputBounds.defaultMinZoom);
      expect(RendererGestureViewBounds.maxZoom, FractalViewInputBounds.maxZoom);
      expect(RendererGestureViewBounds.minPan, FractalViewInputBounds.minPan);
      expect(RendererGestureViewBounds.maxPan, FractalViewInputBounds.maxPan);
    });

    test('does not rubber-band zoom targets inside controller bounds', () {
      expect(
        RendererGestureViewBounds.rubberBand(
          5e11,
          RendererGestureViewBounds.minZoom,
          RendererGestureViewBounds.maxZoom,
        ),
        5e11,
      );
    });
  });
}
