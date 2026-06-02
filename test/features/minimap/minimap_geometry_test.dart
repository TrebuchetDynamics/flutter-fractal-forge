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
    test('matches the existing tap-to-pan mapping for valid inputs', () {
      final pan = MiniMapGeometry.panForTap(
        localPosition: const Offset(120, 0),
        minimapSize: const Size(120, 120),
        zoom: 2.0,
      );

      expect(pan.dx, 0.5);
      expect(pan.dy, -0.5);
    });

    test('uses neutral zoom for malformed zoom samples', () {
      final pan = MiniMapGeometry.panForTap(
        localPosition: const Offset(120, 0),
        minimapSize: const Size(120, 120),
        zoom: 0.0,
      );

      expect(pan.dx, 1.0);
      expect(pan.dy, -1.0);
    });
  });
}
