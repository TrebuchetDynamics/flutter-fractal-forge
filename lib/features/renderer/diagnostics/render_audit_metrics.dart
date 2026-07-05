import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Objective image-health metrics for catalog-wide render audits.
///
/// These metrics are intentionally renderer-agnostic: integration tests can
/// feed captured GPU frames, while unit tests can feed synthetic images.
final class RenderAuditMetrics {
  static const int minimumPngBytes = 500;
  static const int minimumUniqueRgbColors = 16;
  static const double minimumLuminanceStdDev = 3.0;
  static const double minimumNonTransparentPixelRatio = 0.05;
  static const double maximumAllBlackPixelRatio = 0.98;
  static const double maximumMostlyBlackPixelRatio = 0.90;

  final int width;
  final int height;
  final int pngBytes;
  final int uniqueRgbColors;
  final double blackPixelRatio;
  final double nonBlackPixelRatio;
  final double transparentPixelRatio;
  final double nonTransparentRatio;
  final double luminanceMean;
  final double luminanceStdDev;
  final double dominantColorRatio;
  final String verdict;
  final List<String> warnings;

  const RenderAuditMetrics({
    required this.width,
    required this.height,
    required this.pngBytes,
    required this.uniqueRgbColors,
    required this.blackPixelRatio,
    required this.nonBlackPixelRatio,
    required this.transparentPixelRatio,
    required this.nonTransparentRatio,
    required this.luminanceMean,
    required this.luminanceStdDev,
    required this.dominantColorRatio,
    required this.verdict,
    required this.warnings,
  });

  factory RenderAuditMetrics.fromImage(
    img.Image image, {
    int pngBytes = 0,
    int? expectedSize,
  }) {
    final total = image.width * image.height;
    var transparent = 0;
    var black = 0;
    var nonBlack = 0;
    var luminanceSum = 0.0;
    var luminanceSquaredSum = 0.0;
    final uniqueColors = <int>{};
    final buckets = <int, int>{};

    for (final pixel in image) {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt();
      final rgb = (r << 16) | (g << 8) | b;
      uniqueColors.add(rgb);

      final luminance = _luminance(r, g, b);
      luminanceSum += luminance;
      luminanceSquaredSum += luminance * luminance;

      if (a <= 16) {
        transparent++;
        continue;
      }

      final bucket = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;

      if (r <= 8 && g <= 8 && b <= 8) {
        black++;
      } else {
        nonBlack++;
      }
    }

    final nonTransparent = total - transparent;
    final mean = total == 0 ? 0.0 : luminanceSum / total;
    final variance =
        total == 0 ? 0.0 : luminanceSquaredSum / total - mean * mean;
    final dominant = buckets.values.fold<int>(0, math.max);

    final blackPixelRatio = total == 0 ? 0.0 : black / total;
    final nonBlackPixelRatio = total == 0 ? 0.0 : nonBlack / total;
    final transparentPixelRatio = total == 0 ? 0.0 : transparent / total;
    final nonTransparentRatio = total == 0 ? 0.0 : nonTransparent / total;
    final luminanceStdDev = math.sqrt(math.max(0.0, variance));
    final dominantColorRatio =
        nonTransparent == 0 ? 0.0 : dominant / nonTransparent;

    final warnings = <String>[];
    if (expectedSize != null &&
        (image.width != expectedSize || image.height != expectedSize)) {
      warnings.add(
        'dimensions ${image.width}x${image.height}, expected ${expectedSize}x$expectedSize',
      );
    }
    if (pngBytes > 0 && pngBytes < minimumPngBytes) {
      warnings.add('png bytes $pngBytes < $minimumPngBytes');
    }
    if (nonTransparentRatio < minimumNonTransparentPixelRatio) {
      warnings.add(
        'non-transparent pixel ratio ${nonTransparentRatio.toStringAsFixed(4)} < $minimumNonTransparentPixelRatio',
      );
    }
    if (blackPixelRatio >= maximumAllBlackPixelRatio) {
      warnings.add(
        'black pixel ratio ${blackPixelRatio.toStringAsFixed(4)} >= $maximumAllBlackPixelRatio',
      );
    } else if (blackPixelRatio >= maximumMostlyBlackPixelRatio) {
      warnings.add(
        'black pixel ratio ${blackPixelRatio.toStringAsFixed(4)} >= $maximumMostlyBlackPixelRatio',
      );
    }
    if (uniqueColors.length < minimumUniqueRgbColors) {
      warnings.add(
        'unique RGB colors ${uniqueColors.length} < $minimumUniqueRgbColors',
      );
    }
    if (luminanceStdDev < minimumLuminanceStdDev) {
      warnings.add(
        'luminance stddev ${luminanceStdDev.toStringAsFixed(2)} < $minimumLuminanceStdDev',
      );
    }

    return RenderAuditMetrics(
      width: image.width,
      height: image.height,
      pngBytes: pngBytes,
      uniqueRgbColors: uniqueColors.length,
      blackPixelRatio: blackPixelRatio,
      nonBlackPixelRatio: nonBlackPixelRatio,
      transparentPixelRatio: transparentPixelRatio,
      nonTransparentRatio: nonTransparentRatio,
      luminanceMean: mean,
      luminanceStdDev: luminanceStdDev,
      dominantColorRatio: dominantColorRatio,
      verdict: _verdict(
        nonTransparentRatio: nonTransparentRatio,
        blackPixelRatio: blackPixelRatio,
        uniqueRgbColors: uniqueColors.length,
        luminanceStdDev: luminanceStdDev,
      ),
      warnings: List.unmodifiable(warnings),
    );
  }

  Map<String, Object> toJson() => {
        'width': width,
        'height': height,
        'pngBytes': pngBytes,
        'uniqueRgbColors': uniqueRgbColors,
        'blackPixelRatio': _round(blackPixelRatio),
        'nonBlackPixelRatio': _round(nonBlackPixelRatio),
        'transparentPixelRatio': _round(transparentPixelRatio),
        'nonTransparentRatio': _round(nonTransparentRatio),
        'luminanceMean': _round(luminanceMean),
        'luminanceStdDev': _round(luminanceStdDev),
        'dominantColorRatio': _round(dominantColorRatio),
        'verdict': verdict,
        'warnings': warnings,
      };

  static String _verdict({
    required double nonTransparentRatio,
    required double blackPixelRatio,
    required int uniqueRgbColors,
    required double luminanceStdDev,
  }) {
    if (nonTransparentRatio < minimumNonTransparentPixelRatio) {
      return 'transparent';
    }
    if (blackPixelRatio >= maximumAllBlackPixelRatio) return 'all-black';
    if (blackPixelRatio >= maximumMostlyBlackPixelRatio) return 'mostly-black';
    if (uniqueRgbColors < minimumUniqueRgbColors) return 'low-color';
    if (luminanceStdDev < minimumLuminanceStdDev) return 'flat';
    return 'pass';
  }
}

double _luminance(int r, int g, int b) => 0.2126 * r + 0.7152 * g + 0.0722 * b;

double _round(double value) => double.parse(value.toStringAsFixed(4));
