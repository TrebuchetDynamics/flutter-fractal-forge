// ignore_for_file: avoid_print
library;

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';

void main() {
  test('CPU Mandelbrot canonical render is stable + non-blocky', () {
    const w = 128;
    const h = 128;

    const moduleId = 'mandelbrot';
    const panX = -0.5;
    const panY = 0.0;
    const zoom = 1.0;
    const baseIters = 220;
    const bailout = 4.0;
    const aa = 4;

    final extra = (math.log(math.max(zoom, 1.0)) / math.ln2 * 32.0).round();
    final iters = (baseIters + extra).clamp(50, 5000);

    final resp = renderCpuFrameInIsolate(
      CpuRenderRequest(
        moduleId: moduleId,
        panX: panX,
        panY: panY,
        zoom: zoom,
        iterations: iters,
        bailout: bailout,
        juliaCX: -0.8,
        juliaCY: 0.156,
        width: w,
        height: h,
        sampleCount: aa,
      ),
    );

    // Quick sanity checks.
    final rgba = resp.rgba;
    int nonBlack = 0;
    final lumBins = List<int>.filled(32, 0);
    double lumAt(int px, int py) {
      final idx = (py * w + px) * 4;
      final r = rgba[idx];
      final g = rgba[idx + 1];
      final b = rgba[idx + 2];
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final idx = (y * w + x) * 4;
        if (rgba[idx] > 8 || rgba[idx + 1] > 8 || rgba[idx + 2] > 8) {
          nonBlack++;
        }
        final l = lumAt(x, y);
        final b =
            (l / 256.0 * lumBins.length).floor().clamp(0, lumBins.length - 1);
        lumBins[b]++;
      }
    }

    expect(nonBlack / (w * h), greaterThan(0.10),
        reason: 'Should not be mostly black');

    // Not gradient-only / flat: require some luminance diversity.
    final nonZeroBins = lumBins.where((c) => c > (w * h * 0.001)).length;
    expect(nonZeroBins, greaterThanOrEqualTo(6),
        reason: 'Too few luminance bins (flat/gradient-only)');

    // Blockiness metric: large flat 8x8 blocks are a regression.
    // We compute the mean per-block luminance and count identical adjacent blocks.

    const bs = 8;
    final bw = w ~/ bs;
    final bh = h ~/ bs;
    final block = List<double>.filled(bw * bh, 0);

    for (int by = 0; by < bh; by++) {
      for (int bx = 0; bx < bw; bx++) {
        double acc = 0;
        for (int y = 0; y < bs; y++) {
          for (int x = 0; x < bs; x++) {
            acc += lumAt(bx * bs + x, by * bs + y);
          }
        }
        block[by * bw + bx] = acc / (bs * bs);
      }
    }

    int sameAdj = 0;
    int adj = 0;
    for (int by = 0; by < bh; by++) {
      for (int bx = 0; bx < bw; bx++) {
        final v = block[by * bw + bx];
        if (bx + 1 < bw) {
          adj++;
          if ((v - block[by * bw + (bx + 1)]).abs() < 0.25) sameAdj++;
        }
        if (by + 1 < bh) {
          adj++;
          if ((v - block[(by + 1) * bw + bx]).abs() < 0.25) sameAdj++;
        }
      }
    }

    final ratio = sameAdj / adj;
    // Empirical: a properly rendered Mandelbrot should have lots of boundaries,
    // so adjacent blocks shouldn't all be identical.
    expect(ratio, lessThan(0.80),
        reason: 'Too many identical adjacent blocks (blocky render)');
  });
}
