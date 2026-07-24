/// Pure bounds for effect inputs accepted by [FractalController].
///
/// Glow values are bounded shader-control inputs: finite values and infinities
/// clamp to explicit UI limits, while NaN falls back to the last known-good
/// value instead of being promoted to a maximum by [double.clamp].
/// Kaleidoscope rotation is intentionally unbounded, but shader uniforms still
/// need finite angles, so non-finite candidates preserve the last finite angle.
final class FractalEffectInputBounds {
  static const double minGlowSigma = 0.1;
  static const double maxGlowSigma = 5.0;
  static const double minGlowIntensity = 0.0;
  static const double maxGlowIntensity = 1.0;
  static const double minFluidStrength = 0.0;
  static const double maxFluidStrength = 2.0;

  const FractalEffectInputBounds._();

  static double normalizeGlowSigma({
    required double candidate,
    required double current,
  }) {
    return _normalizeBounded(
      candidate: candidate,
      current: current,
      minValue: minGlowSigma,
      maxValue: maxGlowSigma,
    );
  }

  static double normalizeGlowIntensity({
    required double candidate,
    required double current,
  }) {
    return _normalizeBounded(
      candidate: candidate,
      current: current,
      minValue: minGlowIntensity,
      maxValue: maxGlowIntensity,
    );
  }

  static double normalizeFluidStrength({
    required double candidate,
    required double current,
  }) {
    return _normalizeBounded(
      candidate: candidate,
      current: current,
      minValue: minFluidStrength,
      maxValue: maxFluidStrength,
    );
  }

  static double normalizeKaleidoscopeRotation({
    required double candidate,
    required double current,
  }) {
    if (candidate.isFinite) return candidate;
    return current.isFinite ? current : 0.0;
  }

  static double _normalizeBounded({
    required double candidate,
    required double current,
    required double minValue,
    required double maxValue,
  }) {
    final fallback = current.isNaN ? minValue : current;
    if (candidate.isNaN) {
      return fallback.clamp(minValue, maxValue).toDouble();
    }
    return candidate.clamp(minValue, maxValue).toDouble();
  }
}
