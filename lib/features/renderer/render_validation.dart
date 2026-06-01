import 'dart:math' as math;
import 'dart:typed_data';

const int _rgbaStride = 4;
const int _blackThreshold = 8;
const int _differenceThreshold = 12;
const double _minimumNonBlackRatio = 0.01;
const double _minimumProgressionRatio = 0.002;
const double _minimumIterationDeltaRatio = 0.01;

class _RenderFrameGeometry {
  final int width;
  final int height;
  final int totalPixels;
  final int centerIndex;

  const _RenderFrameGeometry._({
    required this.width,
    required this.height,
    required this.totalPixels,
    required this.centerIndex,
  });

  factory _RenderFrameGeometry({required int width, required int height}) {
    if (width <= 0 || height <= 0) {
      return _RenderFrameGeometry._(
        width: width,
        height: height,
        totalPixels: 0,
        centerIndex: -1,
      );
    }

    final totalPixels = width * height;
    final cx = (width / 2).floor();
    final cy = (height / 2).floor();
    return _RenderFrameGeometry._(
      width: width,
      height: height,
      totalPixels: totalPixels,
      centerIndex: (cy * width + cx) * _rgbaStride,
    );
  }

  bool canReadCenter(Uint8List frame) =>
      centerIndex >= 0 && centerIndex + 2 < frame.length;

  int readablePixelCount(Uint8List frame) =>
      math.min(totalPixels, frame.length ~/ _rgbaStride);

  bool hasCompleteFrame(Uint8List frame) =>
      totalPixels > 0 && readablePixelCount(frame) == totalPixels;
}

bool _isNonBlack(Uint8List frame, int index) =>
    frame[index] > _blackThreshold ||
    frame[index + 1] > _blackThreshold ||
    frame[index + 2] > _blackThreshold;

bool _isVisiblyDifferent(Uint8List frameA, Uint8List frameB, int index) {
  final dr = (frameB[index] - frameA[index]).abs();
  final dg = (frameB[index + 1] - frameA[index + 1]).abs();
  final db = (frameB[index + 2] - frameA[index + 2]).abs();
  return dr + dg + db > _differenceThreshold;
}

int _countNonBlackPixels(Uint8List frame, int readablePixels) {
  int nonBlack = 0;
  for (int pixel = 0; pixel < readablePixels; pixel++) {
    final i = pixel * _rgbaStride;
    if (_isNonBlack(frame, i)) {
      nonBlack++;
    }
  }
  return nonBlack;
}

int _countDifferentPixels({
  required Uint8List frameA,
  required Uint8List frameB,
  required int readablePixels,
}) {
  int different = 0;
  for (int pixel = 0; pixel < readablePixels; pixel++) {
    final i = pixel * _rgbaStride;
    if (_isVisiblyDifferent(frameA, frameB, i)) {
      different++;
    }
  }
  return different;
}

class RenderFrameStats {
  final int centerR;
  final int centerG;
  final int centerB;
  final double nonBlackRatio;
  final bool centerNonBlack;
  final bool histogramSane;

  const RenderFrameStats({
    required this.centerR,
    required this.centerG,
    required this.centerB,
    required this.nonBlackRatio,
    required this.centerNonBlack,
    required this.histogramSane,
  });

  String summary(String backend) {
    return '[renderer] render_frame_stats backend=$backend center=$centerR,$centerG,$centerB non_black_ratio=${nonBlackRatio.toStringAsFixed(4)} histogram_sane=$histogramSane';
  }
}

RenderFrameStats validateRenderFrame({
  required Uint8List frame,
  required int width,
  required int height,
}) {
  final geometry = _RenderFrameGeometry(width: width, height: height);
  final cIndex = geometry.centerIndex;
  final centerR = geometry.canReadCenter(frame) ? frame[cIndex] : 0;
  final centerG = geometry.canReadCenter(frame) ? frame[cIndex + 1] : 0;
  final centerB = geometry.canReadCenter(frame) ? frame[cIndex + 2] : 0;

  final centerNonBlack =
      geometry.canReadCenter(frame) && _isNonBlack(frame, cIndex);

  final readablePixels = geometry.readablePixelCount(frame);
  final nonBlack = _countNonBlackPixels(frame, readablePixels);

  final nonBlackRatio =
      geometry.totalPixels == 0 ? 0.0 : nonBlack / geometry.totalPixels;
  final histogramSane = nonBlackRatio > _minimumNonBlackRatio;

  return RenderFrameStats(
    centerR: centerR,
    centerG: centerG,
    centerB: centerB,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: centerNonBlack,
    histogramSane: histogramSane,
  );
}

class RenderCheckResult {
  final int centerR;
  final int centerG;
  final int centerB;
  final double nonBlackRatio;
  final bool centerNonBlack;
  final bool histogramSane;
  final bool frameProgressed;
  final bool iterationDeltaVisible;

  const RenderCheckResult({
    required this.centerR,
    required this.centerG,
    required this.centerB,
    required this.nonBlackRatio,
    required this.centerNonBlack,
    required this.histogramSane,
    required this.frameProgressed,
    required this.iterationDeltaVisible,
  });

  bool get pass =>
      centerNonBlack &&
      histogramSane &&
      frameProgressed &&
      iterationDeltaVisible;

  String summary(String backend) {
    return '[renderer] render_check backend=$backend pass=$pass center=$centerR,$centerG,$centerB non_black_ratio=${nonBlackRatio.toStringAsFixed(4)} frame_progressed=$frameProgressed iter_delta=$iterationDeltaVisible';
  }
}

RenderCheckResult validateRenderPair({
  required Uint8List frameA,
  required Uint8List frameB,
  required int width,
  required int height,
}) {
  final geometry = _RenderFrameGeometry(width: width, height: height);
  final cIndex = geometry.centerIndex;
  final centerR = geometry.canReadCenter(frameB) ? frameB[cIndex] : 0;
  final centerG = geometry.canReadCenter(frameB) ? frameB[cIndex + 1] : 0;
  final centerB = geometry.canReadCenter(frameB) ? frameB[cIndex + 2] : 0;

  final centerNonBlack =
      geometry.canReadCenter(frameB) && _isNonBlack(frameB, cIndex);

  final frameBReadablePixels = geometry.readablePixelCount(frameB);
  final comparablePixels = math.min(
    geometry.readablePixelCount(frameA),
    frameBReadablePixels,
  );
  final nonBlack = _countNonBlackPixels(frameB, frameBReadablePixels);
  final different = _countDifferentPixels(
    frameA: frameA,
    frameB: frameB,
    readablePixels: comparablePixels,
  );
  final hasCompletePair =
      geometry.hasCompleteFrame(frameA) && geometry.hasCompleteFrame(frameB);

  final nonBlackRatio =
      geometry.totalPixels == 0 ? 0.0 : nonBlack / geometry.totalPixels;
  final histogramSane = nonBlackRatio > _minimumNonBlackRatio;
  // Progression is a whole-frame claim; a truncated frame can still prove the
  // current histogram, but cannot prove frame-to-frame movement.
  final progressionRatio = geometry.totalPixels == 0 || !hasCompletePair
      ? 0.0
      : different / geometry.totalPixels;
  final frameProgressed = progressionRatio > _minimumProgressionRatio;
  final iterationDeltaVisible = progressionRatio > _minimumIterationDeltaRatio;

  return RenderCheckResult(
    centerR: centerR,
    centerG: centerG,
    centerB: centerB,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: centerNonBlack,
    histogramSane: histogramSane,
    frameProgressed: frameProgressed,
    iterationDeltaVisible: iterationDeltaVisible,
  );
}
