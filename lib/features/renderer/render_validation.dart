import 'dart:math' as math;
import 'dart:typed_data';

const int _rgbaStride = 4;

/// Numeric thresholds used by render-health probes.
///
/// Keeping these cutoffs in one value object makes the pass/fail contract
/// replayable from tests instead of scattering magic constants through the
/// frame and pair validators.
class RenderValidationThresholds {
  final int blackThreshold;
  final int differenceThreshold;
  final double minimumNonBlackRatio;
  final double minimumProgressionRatio;
  final double minimumIterationDeltaRatio;

  static const defaults = RenderValidationThresholds();

  const RenderValidationThresholds({
    this.blackThreshold = 8,
    this.differenceThreshold = 12,
    this.minimumNonBlackRatio = 0.01,
    this.minimumProgressionRatio = 0.002,
    this.minimumIterationDeltaRatio = 0.01,
  })  : assert(blackThreshold >= 0),
        assert(differenceThreshold >= 0),
        assert(minimumNonBlackRatio >= 0.0),
        assert(minimumProgressionRatio >= 0.0),
        assert(minimumIterationDeltaRatio >= 0.0);

  bool isNonBlackPixel(int r, int g, int b) =>
      r > blackThreshold || g > blackThreshold || b > blackThreshold;

  bool isVisiblyDifferent({
    required int rA,
    required int gA,
    required int bA,
    required int rB,
    required int gB,
    required int bB,
  }) {
    final dr = (rB - rA).abs();
    final dg = (gB - gA).abs();
    final db = (bB - bA).abs();
    return dr + dg + db > differenceThreshold;
  }

  bool histogramSaneFor(double nonBlackRatio) =>
      nonBlackRatio > minimumNonBlackRatio;

  bool frameProgressedFor(double progressionRatio) =>
      progressionRatio > minimumProgressionRatio;

  bool iterationDeltaVisibleFor(double progressionRatio) =>
      progressionRatio > minimumIterationDeltaRatio;
}

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
    RenderValidationThresholds.defaults.isNonBlackPixel(
      frame[index],
      frame[index + 1],
      frame[index + 2],
    );

bool _isVisiblyDifferent(Uint8List frameA, Uint8List frameB, int index) =>
    RenderValidationThresholds.defaults.isVisiblyDifferent(
      rA: frameA[index],
      gA: frameA[index + 1],
      bA: frameA[index + 2],
      rB: frameB[index],
      gB: frameB[index + 1],
      bB: frameB[index + 2],
    );

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

/// Replayable center-pixel read used by render validation.
///
/// Center sampling is shared by single-frame and pair validators. Exposing the
/// read separately makes the odd/even center convention and truncated-frame
/// fallback replayable without inferring it from final pass/fail booleans.
class RenderCenterSample {
  final int r;
  final int g;
  final int b;
  final bool readable;
  final bool nonBlack;

  const RenderCenterSample({
    required this.r,
    required this.g,
    required this.b,
    required this.readable,
    required this.nonBlack,
  });

  const RenderCenterSample.unreadable()
      : r = 0,
        g = 0,
        b = 0,
        readable = false,
        nonBlack = false;
}

/// Replayable counters used by frame validation.
///
/// This separates byte-buffer sampling from threshold decisions so truncated
/// frames and invalid dimensions can be characterized without inferring hidden
/// state from the final pass/fail booleans.
class RenderFrameSample {
  final int totalPixels;
  final int readablePixels;
  final int nonBlackPixels;
  final bool centerReadable;

  const RenderFrameSample({
    required this.totalPixels,
    required this.readablePixels,
    required this.nonBlackPixels,
    required this.centerReadable,
  });

  bool get hasCompleteFrame => totalPixels > 0 && readablePixels == totalPixels;

  double get nonBlackRatio =>
      totalPixels == 0 ? 0.0 : nonBlackPixels / totalPixels;
}

/// Replayable counters used by pair validation.
class RenderPairSample {
  final RenderFrameSample frameB;
  final int comparablePixels;
  final int differentPixels;
  final bool hasCompletePair;

  const RenderPairSample({
    required this.frameB,
    required this.comparablePixels,
    required this.differentPixels,
    required this.hasCompletePair,
  });

  double get progressionRatio => frameB.totalPixels == 0 || !hasCompletePair
      ? 0.0
      : differentPixels / frameB.totalPixels;
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

RenderFrameSample sampleRenderFrame({
  required Uint8List frame,
  required int width,
  required int height,
}) {
  final geometry = _RenderFrameGeometry(width: width, height: height);
  final readablePixels = geometry.readablePixelCount(frame);
  return RenderFrameSample(
    totalPixels: geometry.totalPixels,
    readablePixels: readablePixels,
    nonBlackPixels: _countNonBlackPixels(frame, readablePixels),
    centerReadable: geometry.canReadCenter(frame),
  );
}

RenderCenterSample sampleRenderCenter({
  required Uint8List frame,
  required int width,
  required int height,
}) {
  final geometry = _RenderFrameGeometry(width: width, height: height);
  if (!geometry.canReadCenter(frame)) {
    return const RenderCenterSample.unreadable();
  }

  final cIndex = geometry.centerIndex;
  return RenderCenterSample(
    r: frame[cIndex],
    g: frame[cIndex + 1],
    b: frame[cIndex + 2],
    readable: true,
    nonBlack: _isNonBlack(frame, cIndex),
  );
}

RenderFrameStats validateRenderFrame({
  required Uint8List frame,
  required int width,
  required int height,
}) {
  final sample = sampleRenderFrame(frame: frame, width: width, height: height);
  final center = sampleRenderCenter(
    frame: frame,
    width: width,
    height: height,
  );

  final nonBlackRatio = sample.nonBlackRatio;
  final histogramSane =
      RenderValidationThresholds.defaults.histogramSaneFor(nonBlackRatio);

  return RenderFrameStats(
    centerR: center.r,
    centerG: center.g,
    centerB: center.b,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: center.nonBlack,
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

RenderPairSample sampleRenderPair({
  required Uint8List frameA,
  required Uint8List frameB,
  required int width,
  required int height,
}) {
  final geometry = _RenderFrameGeometry(width: width, height: height);
  final frameBSample = sampleRenderFrame(
    frame: frameB,
    width: width,
    height: height,
  );
  final comparablePixels = math.min(
    geometry.readablePixelCount(frameA),
    frameBSample.readablePixels,
  );
  return RenderPairSample(
    frameB: frameBSample,
    comparablePixels: comparablePixels,
    differentPixels: _countDifferentPixels(
      frameA: frameA,
      frameB: frameB,
      readablePixels: comparablePixels,
    ),
    hasCompletePair:
        geometry.hasCompleteFrame(frameA) && geometry.hasCompleteFrame(frameB),
  );
}

RenderCheckResult validateRenderPair({
  required Uint8List frameA,
  required Uint8List frameB,
  required int width,
  required int height,
}) {
  final sample = sampleRenderPair(
    frameA: frameA,
    frameB: frameB,
    width: width,
    height: height,
  );
  final center = sampleRenderCenter(
    frame: frameB,
    width: width,
    height: height,
  );

  final nonBlackRatio = sample.frameB.nonBlackRatio;
  final histogramSane =
      RenderValidationThresholds.defaults.histogramSaneFor(nonBlackRatio);
  // Progression is a whole-frame claim; a truncated frame can still prove the
  // current histogram, but cannot prove frame-to-frame movement.
  final progressionRatio = sample.progressionRatio;
  final frameProgressed =
      RenderValidationThresholds.defaults.frameProgressedFor(progressionRatio);
  final iterationDeltaVisible = RenderValidationThresholds.defaults
      .iterationDeltaVisibleFor(progressionRatio);

  return RenderCheckResult(
    centerR: center.r,
    centerG: center.g,
    centerB: center.b,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: center.nonBlack,
    histogramSane: histogramSane,
    frameProgressed: frameProgressed,
    iterationDeltaVisible: iterationDeltaVisible,
  );
}
