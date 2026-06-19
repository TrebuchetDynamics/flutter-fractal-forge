import 'package:flutter_fractals/features/catalog/launch_visual_metrics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('LaunchVisualMetrics', () {
    test('passes a varied launch-style image', () {
      final image = img.Image(width: 32, height: 32);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixelRgb(
            x,
            y,
            (x * 8) % 256,
            (y * 8) % 256,
            ((x + y) * 4) % 256,
          );
        }
      }

      final metrics = LaunchVisualMetrics.fromImage(image);

      expect(metrics.verdict, 'pass');
      expect(metrics.centerDetailScore, greaterThan(0));
      expect(metrics.edgeDetailScore, greaterThan(0));
      expect(metrics.nonTransparentRatio, 1.0);
      expect(metrics.toJson(), containsPair('verdict', 'pass'));
    });

    test('flags a flat opaque image as needing framing', () {
      final image = img.Image(width: 32, height: 32);
      img.fill(image, color: img.ColorRgb8(24, 24, 24));

      final metrics = LaunchVisualMetrics.fromImage(image);

      expect(metrics.verdict, 'needs-framing');
      expect(metrics.centerDetailScore, 0.0);
      expect(metrics.edgeDetailScore, 0.0);
    });

    test('flags a transparent image as fallback preview', () {
      final image = img.Image(width: 16, height: 16, numChannels: 4);
      img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

      final metrics = LaunchVisualMetrics.fromImage(image);

      expect(metrics.verdict, 'fallback-preview');
      expect(metrics.nonTransparentRatio, 0.0);
    });
  });
}
