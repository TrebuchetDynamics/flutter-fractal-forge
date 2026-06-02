import 'dart:ui';

import 'package:flutter_fractals/features/minimap/geometry/minimap_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MiniMapGeometry.viewportRect', () {
    test('preserves the rendered viewport aspect ratio', () {
      final rect = MiniMapGeometry.viewportRect(
        pan: Offset.zero,
        zoom: 2.0,
        minimapSize: const Size(240, 240),
        viewportSize: const Size(1600, 900),
      );

      expect(rect.center, const Offset(120, 120));
      expect(rect.width / rect.height, closeTo(16 / 9, 1e-9));
    });

    test('keeps square viewport dimensions compatible with legacy mapping', () {
      final rect = MiniMapGeometry.viewportRect(
        pan: const Offset(1, -1),
        zoom: 2.0,
        minimapSize: const Size(120, 120),
        viewportSize: const Size(600, 600),
      );

      expect(rect.center, const Offset(90, 30));
      expect(rect.width, 30);
      expect(rect.height, 30);
    });

    test('normalizes malformed zoom samples instead of producing NaN rects',
        () {
      final rect = MiniMapGeometry.viewportRect(
        pan: const Offset(double.nan, double.infinity),
        zoom: double.nan,
        minimapSize: const Size(120, 120),
        viewportSize: Size.zero,
      );

      expect(rect.center, const Offset(60, 60));
      expect(rect.width, 60);
      expect(rect.height, 60);
    });
  });

  group('MiniMapGeometry.panForTap', () {
    test('is the inverse of viewport center mapping', () {
      const minimapSize = Size(120, 120);
      const viewportSize = Size(600, 600);
      const tap = Offset(120, 0);

      for (final zoom in [0.5, 1.0, 2.0, 8.0]) {
        final pan = MiniMapGeometry.panForTap(
          localPosition: tap,
          minimapSize: minimapSize,
          zoom: zoom,
        );
        final rect = MiniMapGeometry.viewportRect(
          pan: pan,
          zoom: zoom,
          minimapSize: minimapSize,
          viewportSize: viewportSize,
        );

        expect(rect.center.dx, closeTo(tap.dx, 1e-9), reason: 'zoom=$zoom');
        expect(rect.center.dy, closeTo(tap.dy, 1e-9), reason: 'zoom=$zoom');
      }
    });

    test('maps taps to absolute minimap coordinates independent of zoom', () {
      final zoomedOut = MiniMapGeometry.panForTap(
        localPosition: const Offset(120, 0),
        minimapSize: const Size(120, 120),
        zoom: 0.5,
      );
      final zoomedIn = MiniMapGeometry.panForTap(
        localPosition: const Offset(120, 0),
        minimapSize: const Size(120, 120),
        zoom: 8.0,
      );

      expect(zoomedOut, const Offset(2.0, -2.0));
      expect(zoomedIn, zoomedOut);
    });
  });
}
