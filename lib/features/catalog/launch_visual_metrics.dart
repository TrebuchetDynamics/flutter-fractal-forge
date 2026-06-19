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
    final luminance = _luminanceGrid(image);
    final centerDetailScore = _detailScore(
      luminance,
      left: image.width ~/ 4,
      top: image.height ~/ 4,
      right: (image.width * 3) ~/ 4,
      bottom: (image.height * 3) ~/ 4,
    );
    final edgeInset = math.max(1, math.min(image.width, image.height) ~/ 8);
    final edgeDetailScore = _edgeDetailScore(luminance, edgeInset: edgeInset);
    final luminanceStdDev = _stdDev(luminance.expand((row) => row));
    final dominantColorRatio = _dominantColorRatio(image);
    final nonTransparentRatio = _nonTransparentRatio(image);
    final verdict = _verdict(
      centerDetailScore: centerDetailScore,
      edgeDetailScore: edgeDetailScore,
      luminanceStdDev: luminanceStdDev,
      dominantColorRatio: dominantColorRatio,
      nonTransparentRatio: nonTransparentRatio,
    );

    return LaunchVisualMetrics(
      centerDetailScore: centerDetailScore,
      edgeDetailScore: edgeDetailScore,
      luminanceStdDev: luminanceStdDev,
      dominantColorRatio: dominantColorRatio,
      nonTransparentRatio: nonTransparentRatio,
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

List<List<double>> _luminanceGrid(img.Image image) {
  return List.generate(image.height, (y) {
    return List.generate(image.width, (x) {
      final pixel = image.getPixel(x, y);
      return _luminance(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
    });
  });
}

double _luminance(int r, int g, int b) => 0.2126 * r + 0.7152 * g + 0.0722 * b;

double _detailScore(
  List<List<double>> luminance, {
  required int left,
  required int top,
  required int right,
  required int bottom,
}) {
  final values = <double>[];
  final safeTop = top.clamp(0, luminance.length);
  final safeBottom = bottom.clamp(safeTop, luminance.length);
  for (var y = safeTop; y < safeBottom; y++) {
    final row = luminance[y];
    final safeLeft = left.clamp(0, row.length);
    final safeRight = right.clamp(safeLeft, row.length);
    for (var x = safeLeft; x < safeRight; x++) {
      values.add(row[x]);
    }
  }
  return (_stdDev(values) / 64.0).clamp(0.0, 1.0);
}

double _edgeDetailScore(List<List<double>> luminance,
    {required int edgeInset}) {
  final height = luminance.length;
  final width = height == 0 ? 0 : luminance.first.length;
  final values = <double>[];
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (x < edgeInset ||
          y < edgeInset ||
          x >= width - edgeInset ||
          y >= height - edgeInset) {
        values.add(luminance[y][x]);
      }
    }
  }
  return (_stdDev(values) / 64.0).clamp(0.0, 1.0);
}

double _stdDev(Iterable<double> values) {
  var count = 0;
  var sum = 0.0;
  var squaredSum = 0.0;
  for (final value in values) {
    count++;
    sum += value;
    squaredSum += value * value;
  }
  if (count == 0) return 0.0;
  final mean = sum / count;
  return math.sqrt(math.max(0.0, squaredSum / count - mean * mean));
}

double _dominantColorRatio(img.Image image) {
  final buckets = <int, int>{};
  var total = 0;
  for (final pixel in image) {
    if (pixel.a.toInt() <= 16) continue;
    final r = pixel.r.toInt() >> 4;
    final g = pixel.g.toInt() >> 4;
    final b = pixel.b.toInt() >> 4;
    final key = (r << 8) | (g << 4) | b;
    buckets[key] = (buckets[key] ?? 0) + 1;
    total++;
  }
  if (total == 0) return 0.0;
  final dominant = buckets.values.fold<int>(0, math.max);
  return dominant / total;
}

double _nonTransparentRatio(img.Image image) {
  final total = image.width * image.height;
  if (total == 0) return 0.0;
  var nonTransparent = 0;
  for (final pixel in image) {
    if (pixel.a.toInt() > 16) nonTransparent++;
  }
  return nonTransparent / total;
}

double _round(double value) => double.parse(value.toStringAsFixed(4));
