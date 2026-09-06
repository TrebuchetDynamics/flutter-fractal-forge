import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Review signals, not aesthetic grades. Sampling fixes their spatial scale.
Map<String, Object> linuxAuditVisualSignals(img.Image decoded) {
  final small = img.copyResize(decoded,
      width: 64, height: 64, interpolation: img.Interpolation.average);
  double luma(int x, int y) {
    final p = small.getPixel(x, y);
    return (0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b) / 255;
  }

  var edges = 0;
  var energy = 0.0;
  final histogram = List<int>.filled(16, 0);
  final fingerprint = <int>[];
  for (var y = 0; y < 64; y++) {
    for (var x = 0; x < 64; x++) {
      final value = luma(x, y);
      histogram[(value * 15).round().clamp(0, 15)]++;
      if (x % 4 == 0 && y % 4 == 0) fingerprint.add((value * 15).round());
      if (x > 0 && y > 0) {
        final delta =
            ((value - luma(x - 1, y)).abs() + (value - luma(x, y - 1)).abs()) /
                2;
        energy += delta;
        if (delta > 0.15) edges++;
      }
    }
  }
  var entropy = 0.0;
  for (final count in histogram.where((n) => n > 0)) {
    final p = count / 4096;
    entropy -= p * math.log(p) / math.ln2;
  }
  return {
    'luminanceEntropy': entropy,
    'edgeDensity': edges / 3969,
    'edgeEnergy': energy / 3969,
    'fingerprint': fingerprint,
  };
}
