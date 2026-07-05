import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('RenderAuditMetrics', () {
    test('flags an opaque black render', () {
      final image = img.Image(width: 16, height: 16);
      img.fill(image, color: img.ColorRgb8(0, 0, 0));

      final metrics = RenderAuditMetrics.fromImage(
        image,
        pngBytes: 1000,
        expectedSize: 16,
      );

      expect(metrics.verdict, 'all-black');
      expect(metrics.blackPixelRatio, 1.0);
      expect(metrics.nonBlackPixelRatio, 0.0);
      expect(metrics.warnings.join('\n'), contains('black pixel ratio'));
      expect(metrics.toJson(), containsPair('verdict', 'all-black'));
    });

    test('passes a varied opaque render', () {
      final image = img.Image(width: 32, height: 32);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixelRgb(
            x,
            y,
            (x * 17 + y * 3) % 256,
            (y * 19 + x * 5) % 256,
            ((x + y) * 11) % 256,
          );
        }
      }

      final metrics = RenderAuditMetrics.fromImage(
        image,
        pngBytes: 2000,
        expectedSize: 32,
      );

      expect(metrics.verdict, 'pass');
      expect(metrics.blackPixelRatio, lessThan(0.05));
      expect(metrics.uniqueRgbColors, greaterThanOrEqualTo(16));
      expect(metrics.luminanceStdDev, greaterThanOrEqualTo(3.0));
      expect(metrics.warnings, isEmpty);
    });

    test('flags a transparent render', () {
      final image = img.Image(width: 8, height: 8, numChannels: 4);
      img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

      final metrics = RenderAuditMetrics.fromImage(image, expectedSize: 8);

      expect(metrics.verdict, 'transparent');
      expect(metrics.transparentPixelRatio, 1.0);
      expect(metrics.nonTransparentRatio, 0.0);
    });
  });
}
