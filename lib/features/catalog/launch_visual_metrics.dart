import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Objective image metrics used by the launch visual audit.
///
/// These scores are intentionally descriptive. They make first-impression
/// thumbnail review repeatable without deciding long-tail catalog failures.
final class LaunchVisualMetrics {
  static const double _lowDetailThreshold = 0.08;
  static const double _dominantColorThreshold = 0.92;
  static const double _lowLuminanceStdDevThreshold = 3.0;

  final double centerDetailScore;
  final double edgeDetailScore;
  final double luminanceStdDev;
  final double dominantColorRatio;
  final double nonTransparentRatio;
  final String verdict;

  const LaunchVisualMetrics({
    required this.centerDetailScore,
    required this.edgeDetailScore,
    required this.luminanceStdDev,
    required this.dominantColorRatio,
    required this.nonTransparentRatio,
    required this.verdict,
  });

  factory LaunchVisualMetrics.fromImage(img.Image image) {
    final stats = _ImageMetricStats.fromImage(image);
    final centerDetailScore = _detailScore(stats.centerLuminanceStdDev);
    final edgeDetailScore = _detailScore(stats.edgeLuminanceStdDev);
    final verdict = _verdict(
      centerDetailScore: centerDetailScore,
      edgeDetailScore: edgeDetailScore,
      luminanceStdDev: stats.luminanceStdDev,
      dominantColorRatio: stats.dominantColorRatio,
      nonTransparentRatio: stats.nonTransparentRatio,
    );

    return LaunchVisualMetrics(
      centerDetailScore: centerDetailScore,
      edgeDetailScore: edgeDetailScore,
      luminanceStdDev: stats.luminanceStdDev,
      dominantColorRatio: stats.dominantColorRatio,
      nonTransparentRatio: stats.nonTransparentRatio,
      verdict: verdict,
    );
  }

  Map<String, Object> toJson() => {
        'centerDetailScore': _round(centerDetailScore),
        'edgeDetailScore': _round(edgeDetailScore),
        'luminanceStdDev': _round(luminanceStdDev),
        'dominantColorRatio': _round(dominantColorRatio),
        'nonTransparentRatio': _round(nonTransparentRatio),
        'verdict': verdict,
      };

  static String _verdict({
    required double centerDetailScore,
    required double edgeDetailScore,
    required double luminanceStdDev,
    required double dominantColorRatio,
    required double nonTransparentRatio,
  }) {
    if (nonTransparentRatio <= 0.0) return 'fallback-preview';
    if (centerDetailScore < _lowDetailThreshold &&
        edgeDetailScore < _lowDetailThreshold) {
      return 'needs-framing';
    }
    if (dominantColorRatio > _dominantColorThreshold ||
        luminanceStdDev < _lowLuminanceStdDevThreshold) {
      return 'needs-palette';
    }
    return 'pass';
  }
}

final class _ImageMetricStats {
  final double centerLuminanceStdDev;
  final double edgeLuminanceStdDev;
  final double luminanceStdDev;
  final double dominantColorRatio;
  final double nonTransparentRatio;

  const _ImageMetricStats({
    required this.centerLuminanceStdDev,
    required this.edgeLuminanceStdDev,
    required this.luminanceStdDev,
    required this.dominantColorRatio,
    required this.nonTransparentRatio,
  });

  factory _ImageMetricStats.fromImage(img.Image image) {
    final all = _RunningStats();
    final center = _RunningStats();
    final edge = _RunningStats();
    final buckets = <int, int>{};
    var nonTransparent = 0;

    final centerLeft = image.width ~/ 4;
    final centerTop = image.height ~/ 4;
    final centerRight = (image.width * 3) ~/ 4;
    final centerBottom = (image.height * 3) ~/ 4;
    final edgeInset = math.max(1, math.min(image.width, image.height) ~/ 8);

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luminance = _luminance(r, g, b);
        all.add(luminance);

        if (x >= centerLeft &&
            x < centerRight &&
            y >= centerTop &&
            y < centerBottom) {
          center.add(luminance);
        }
        if (x < edgeInset ||
            y < edgeInset ||
            x >= image.width - edgeInset ||
            y >= image.height - edgeInset) {
          edge.add(luminance);
        }

        if (pixel.a.toInt() > 16) {
          nonTransparent++;
          final key = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
          buckets[key] = (buckets[key] ?? 0) + 1;
        }
      }
    }

    final total = image.width * image.height;
    final dominant = buckets.values.fold<int>(0, math.max);
    return _ImageMetricStats(
      centerLuminanceStdDev: center.stdDev,
      edgeLuminanceStdDev: edge.stdDev,
      luminanceStdDev: all.stdDev,
      dominantColorRatio: nonTransparent == 0 ? 0.0 : dominant / nonTransparent,
      nonTransparentRatio: total == 0 ? 0.0 : nonTransparent / total,
    );
  }
}

final class _RunningStats {
  var _count = 0;
  var _sum = 0.0;
  var _squaredSum = 0.0;

  void add(double value) {
    _count++;
    _sum += value;
    _squaredSum += value * value;
  }

  double get stdDev {
    if (_count == 0) return 0.0;
    final mean = _sum / _count;
    return math.sqrt(math.max(0.0, _squaredSum / _count - mean * mean));
  }
}

double _luminance(int r, int g, int b) => 0.2126 * r + 0.7152 * g + 0.0722 * b;

double _detailScore(double luminanceStdDev) =>
    (luminanceStdDev / 64.0).clamp(0.0, 1.0);

double _round(double value) => double.parse(value.toStringAsFixed(4));
