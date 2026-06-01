import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a Uint8List RGBA frame of [w]x[h] pixels, all zeroed (black).
Uint8List _blackFrame(int w, int h) => Uint8List(w * h * 4);

/// Pixel index for (x, y) in a [w]-wide RGBA frame.
int _px(int x, int y, int w) => (y * w + x) * 4;

void main() {
  group('RenderValidationThresholds', () {
    test('exposes default health thresholds as replayable comparisons', () {
      const thresholds = RenderValidationThresholds.defaults;

      expect(thresholds.blackThreshold, 8);
      expect(thresholds.differenceThreshold, 12);
      expect(thresholds.minimumNonBlackRatio, 0.01);
      expect(thresholds.minimumProgressionRatio, 0.002);
      expect(thresholds.minimumIterationDeltaRatio, 0.01);

      expect(thresholds.isNonBlackPixel(8, 8, 8), isFalse);
      expect(thresholds.isNonBlackPixel(9, 0, 0), isTrue);
      expect(
        thresholds.isVisiblyDifferent(
          rA: 0,
          gA: 0,
          bA: 0,
          rB: 4,
          gB: 4,
          bB: 4,
        ),
        isFalse,
      );
      expect(
        thresholds.isVisiblyDifferent(
          rA: 0,
          gA: 0,
          bA: 0,
          rB: 5,
          gB: 4,
          bB: 4,
        ),
        isTrue,
      );
      expect(thresholds.histogramSaneFor(0.01), isFalse);
      expect(thresholds.histogramSaneFor(0.0101), isTrue);
      expect(thresholds.frameProgressedFor(0.002), isFalse);
      expect(thresholds.frameProgressedFor(0.0021), isTrue);
      expect(thresholds.iterationDeltaVisibleFor(0.01), isFalse);
      expect(thresholds.iterationDeltaVisibleFor(0.0101), isTrue);
    });
  });

  group('sampleRenderCenter', () {
    test('exposes even-dimension center sampling and black fallback', () {
      final frame = _blackFrame(4, 4);
      final idx = _px(2, 2, 4);
      frame[idx] = 100;
      frame[idx + 1] = 120;
      frame[idx + 2] = 140;

      final center = sampleRenderCenter(frame: frame, width: 4, height: 4);
      final truncatedCenter = sampleRenderCenter(
        frame: Uint8List(4),
        width: 4,
        height: 4,
      );

      expect(center.readable, isTrue);
      expect(center.r, 100);
      expect(center.g, 120);
      expect(center.b, 140);
      expect(center.nonBlack, isTrue);
      expect(truncatedCenter.readable, isFalse);
      expect(truncatedCenter.r, 0);
      expect(truncatedCenter.g, 0);
      expect(truncatedCenter.b, 0);
      expect(truncatedCenter.nonBlack, isFalse);
    });
  });

  group('sampleRenderFrame', () {
    test('exposes readable pixel counts for truncated frames', () {
      final frame = _blackFrame(3, 1);
      frame[0] = 80;
      frame[4] = 80;

      final sample = sampleRenderFrame(frame: frame, width: 4, height: 2);

      expect(sample.totalPixels, 8);
      expect(sample.readablePixels, 3);
      expect(sample.nonBlackPixels, 2);
      expect(sample.centerReadable, isFalse);
      expect(sample.hasCompleteFrame, isFalse);
      expect(sample.nonBlackRatio, 2 / 8);
    });
  });

  group('sampleRenderPair', () {
    test('exposes comparable pixels and gates progression on complete pairs',
        () {
      final frameA = _blackFrame(2, 1);
      final frameB = _blackFrame(3, 1);
      frameB[0] = 80;
      frameB[4] = 80;
      frameB[8] = 80;

      final sample = sampleRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 3,
        height: 1,
      );

      expect(sample.frameB.totalPixels, 3);
      expect(sample.frameB.readablePixels, 3);
      expect(sample.comparablePixels, 2);
      expect(sample.differentPixels, 2);
      expect(sample.hasCompletePair, isFalse);
      expect(sample.progressionRatio, 0.0);
    });
  });

  group('validateRenderFrame', () {
    test('empty dimensions return invalid black stats instead of crashing', () {
      final stats = validateRenderFrame(
        frame: Uint8List(0),
        width: 0,
        height: 0,
      );

      expect(stats.centerR, 0);
      expect(stats.centerG, 0);
      expect(stats.centerB, 0);
      expect(stats.centerNonBlack, isFalse);
      expect(stats.nonBlackRatio, 0.0);
      expect(stats.histogramSane, isFalse);
    });

    test('negative dimensions are treated as invalid frame geometry', () {
      final frame = _blackFrame(1, 1);
      frame[0] = 80;
      frame[1] = 80;
      frame[2] = 80;

      final stats = validateRenderFrame(
        frame: frame,
        width: -1,
        height: -1,
      );

      expect(stats.centerR, 0);
      expect(stats.centerG, 0);
      expect(stats.centerB, 0);
      expect(stats.centerNonBlack, isFalse);
      expect(stats.nonBlackRatio, 0.0);
      expect(stats.histogramSane, isFalse);
    });

    test('detects all-black frame', () {
      final frame = _blackFrame(4, 4);
      final stats = validateRenderFrame(frame: frame, width: 4, height: 4);

      expect(stats.centerR, 0);
      expect(stats.centerG, 0);
      expect(stats.centerB, 0);
      expect(stats.centerNonBlack, isFalse);
      expect(stats.nonBlackRatio, 0.0);
      expect(stats.histogramSane, isFalse);
    });

    test('detects non-black center pixel', () {
      final frame = _blackFrame(4, 4);
      // center of 4x4 is floor(2), floor(2) = (2,2)
      final idx = _px(2, 2, 4);
      frame[idx] = 100;
      frame[idx + 1] = 150;
      frame[idx + 2] = 200;

      final stats = validateRenderFrame(frame: frame, width: 4, height: 4);

      expect(stats.centerR, 100);
      expect(stats.centerG, 150);
      expect(stats.centerB, 200);
      expect(stats.centerNonBlack, isTrue);
    });

    test('calculates correct nonBlackRatio', () {
      // 8 pixels total; make exactly 4 non-black
      final frame = _blackFrame(4, 2);
      // pixels at (0,0),(1,0),(2,0),(3,0) — first row, r=20 > 8 threshold
      for (int col = 0; col < 4; col++) {
        frame[_px(col, 0, 4)] = 20;
      }
      final stats = validateRenderFrame(frame: frame, width: 4, height: 2);

      expect(stats.nonBlackRatio, closeTo(4 / 8, 1e-9));
    });

    test('histogramSane is false when ratio <= 0.01', () {
      // 100 pixels, only 1 non-black => ratio = 0.01 which is NOT > 0.01
      final frame = _blackFrame(10, 10);
      frame[0] = 20;
      final stats = validateRenderFrame(frame: frame, width: 10, height: 10);

      expect(stats.nonBlackRatio, closeTo(0.01, 1e-9));
      expect(stats.histogramSane, isFalse);
    });

    test('histogramSane is true when ratio > 0.01', () {
      // 100 pixels, 2 non-black => ratio = 0.02 > 0.01
      final frame = _blackFrame(10, 10);
      frame[0] = 20;
      frame[4] = 20; // next pixel (x=1,y=0)
      final stats = validateRenderFrame(frame: frame, width: 10, height: 10);

      expect(stats.nonBlackRatio, closeTo(0.02, 1e-9));
      expect(stats.histogramSane, isTrue);
    });

    test('summary includes backend name', () {
      final frame = _blackFrame(4, 4);
      final stats = validateRenderFrame(frame: frame, width: 4, height: 4);
      final summary = stats.summary('gpu');

      expect(summary, contains('backend=gpu'));
      expect(summary, contains('[renderer]'));
      expect(summary, contains('non_black_ratio='));
      expect(summary, contains('histogram_sane='));
    });

    test('boundary: threshold pixel value of 8 is still counted as black', () {
      final frame = _blackFrame(4, 4);
      // Set center pixel RGB all to exactly 8 — threshold is > 8, so this is black
      final idx = _px(2, 2, 4);
      frame[idx] = 8;
      frame[idx + 1] = 8;
      frame[idx + 2] = 8;

      final stats = validateRenderFrame(frame: frame, width: 4, height: 4);
      expect(stats.centerNonBlack, isFalse);
    });

    test('boundary: pixel value of 9 is counted as non-black', () {
      final frame = _blackFrame(4, 4);
      final idx = _px(2, 2, 4);
      frame[idx] = 9;

      final stats = validateRenderFrame(frame: frame, width: 4, height: 4);
      expect(stats.centerNonBlack, isTrue);
    });
  });

  group('validateRenderPair', () {
    test('empty dimensions return failed check instead of crashing', () {
      final result = validateRenderPair(
        frameA: Uint8List(0),
        frameB: Uint8List(0),
        width: 0,
        height: 0,
      );

      expect(result.centerR, 0);
      expect(result.centerG, 0);
      expect(result.centerB, 0);
      expect(result.centerNonBlack, isFalse);
      expect(result.histogramSane, isFalse);
      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
      expect(result.pass, isFalse);
    });

    test('negative dimensions cannot pass from readable single-pixel frames',
        () {
      final frameA = _blackFrame(1, 1);
      final frameB = _blackFrame(1, 1);
      frameB[0] = 80;
      frameB[1] = 80;
      frameB[2] = 80;

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: -1,
        height: -1,
      );

      expect(result.centerR, 0);
      expect(result.centerG, 0);
      expect(result.centerB, 0);
      expect(result.centerNonBlack, isFalse);
      expect(result.nonBlackRatio, 0.0);
      expect(result.histogramSane, isFalse);
      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
      expect(result.pass, isFalse);
    });

    test('detects frame progression when enough pixels differ', () {
      final frameA = _blackFrame(4, 4);
      final frameB = _blackFrame(4, 4);

      // Make every pixel differ significantly (dr+dg+db > 12)
      for (int i = 0; i < frameB.length; i += 4) {
        frameB[i] = 50;
        frameB[i + 1] = 50;
        frameB[i + 2] = 50;
      }

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 4,
        height: 4,
      );

      expect(result.frameProgressed, isTrue);
      expect(result.iterationDeltaVisible, isTrue);
    });

    test('frameProgressed is false when frames are identical', () {
      final frameA = _blackFrame(4, 4);
      final frameB = Uint8List.fromList(frameA);

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 4,
        height: 4,
      );

      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
    });

    test('iterationDeltaVisible requires > 1% different pixels', () {
      // 100 pixels total; need > 1 different pixel for iterationDeltaVisible
      // Exactly 1 different pixel => 1% which is NOT > 0.01
      final frameA = _blackFrame(10, 10);
      final frameB = Uint8List.fromList(frameA);
      frameB[0] = 100;
      frameB[1] = 100;
      frameB[2] = 100;

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 10,
        height: 10,
      );

      // progressionRatio = 1/100 = 0.01; frameProgressed needs > 0.002 (true)
      expect(result.frameProgressed, isTrue);
      // iterationDeltaVisible needs > 0.01 (false — exactly 0.01)
      expect(result.iterationDeltaVisible, isFalse);
    });

    test('uses frameB readable pixels for histogram when frameA is truncated',
        () {
      final frameA = _blackFrame(1, 1);
      final frameB = _blackFrame(10, 10);

      for (int i = 0; i < frameB.length; i += 4) {
        frameB[i] = 80;
        frameB[i + 1] = 80;
        frameB[i + 2] = 80;
      }

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 10,
        height: 10,
      );

      expect(result.nonBlackRatio, 1.0);
      expect(result.histogramSane, isTrue);
      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
    });

    test('does not report progression from incomplete frame pairs', () {
      final frameA = _blackFrame(1, 1);
      final frameB = _blackFrame(1, 1);
      frameB[0] = 80;
      frameB[1] = 80;
      frameB[2] = 80;

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 10,
        height: 10,
      );

      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
      expect(result.pass, isFalse);
    });

    test('pass is true only when all checks pass', () {
      // Build a 10x10 frame where enough pixels are non-black and different
      final frameA = _blackFrame(10, 10);
      final frameB = _blackFrame(10, 10);

      // Fill all pixels in frameB with colour that exceeds all thresholds
      for (int i = 0; i < frameB.length; i += 4) {
        frameB[i] = 80;
        frameB[i + 1] = 80;
        frameB[i + 2] = 80;
        frameB[i + 3] = 255;
      }

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 10,
        height: 10,
      );

      expect(result.centerNonBlack, isTrue);
      expect(result.histogramSane, isTrue);
      expect(result.frameProgressed, isTrue);
      expect(result.iterationDeltaVisible, isTrue);
      expect(result.pass, isTrue);
    });

    test('pass is false when centerNonBlack is false', () {
      // Non-zero progression but center stays black
      final frameA = _blackFrame(10, 10);
      final frameB = _blackFrame(10, 10);

      // Colour many pixels except the center (5,5)
      for (int row = 0; row < 10; row++) {
        for (int col = 0; col < 10; col++) {
          if (row == 5 && col == 5) continue;
          final i = _px(col, row, 10);
          frameB[i] = 80;
          frameB[i + 1] = 80;
          frameB[i + 2] = 80;
        }
      }

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 10,
        height: 10,
      );

      expect(result.centerNonBlack, isFalse);
      expect(result.pass, isFalse);
    });

    test('handles all-identical frames — no progression', () {
      final frameA = Uint8List.fromList(List.filled(20 * 20 * 4, 50));
      final frameB = Uint8List.fromList(List.filled(20 * 20 * 4, 50));

      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 20,
        height: 20,
      );

      expect(result.frameProgressed, isFalse);
      expect(result.iterationDeltaVisible, isFalse);
    });

    test('summary includes pass status and backend name', () {
      final frameA = _blackFrame(4, 4);
      final frameB = _blackFrame(4, 4);
      final result = validateRenderPair(
        frameA: frameA,
        frameB: frameB,
        width: 4,
        height: 4,
      );
      final summary = result.summary('cpu');

      expect(summary, contains('backend=cpu'));
      expect(summary, contains('pass='));
      expect(summary, contains('[renderer]'));
    });
  });
}
