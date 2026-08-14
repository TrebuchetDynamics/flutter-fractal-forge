/// Immutable normalized measurements derived from a two-dimensional spectrum.
final class FourierSpectrumFeatures {
  FourierSpectrumFeatures({
    required List<double> radialBandPower,
    required this.lowPowerRatio,
    required this.midPowerRatio,
    required this.highPowerRatio,
    required this.centroid,
    required this.bandwidth,
    required this.rolloff85,
    required this.logPowerSlope,
    required this.radialPeakSalience,
    required this.entropy,
    required this.flatness,
    required this.dominantOrientation,
    required this.orientationStrength,
    required this.spectralFlux,
    required this.captureMean,
    required this.captureVariance,
    required this.alphaCoverage,
    required this.width,
    required this.height,
    required this.windowApplied,
    required this.dcRemoved,
  }) : radialBandPower = List<double>.unmodifiable(radialBandPower);

  /// Ten normalized log-radial power bands from coarse to fine detail.
  final List<double> radialBandPower;
  final double lowPowerRatio;
  final double midPowerRatio;
  final double highPowerRatio;
  final double centroid;
  final double bandwidth;
  final double rolloff85;
  final double logPowerSlope;
  final double radialPeakSalience;
  final double entropy;

  /// Geometric-to-arithmetic power ratio, using epsilon `1e-20`.
  final double flatness;
  final double dominantOrientation;
  final double orientationStrength;
  final double spectralFlux;
  final double captureMean;
  final double captureVariance;
  final double alphaCoverage;
  final int width;
  final int height;
  final bool windowApplied;
  final bool dcRemoved;
}
