import 'dart:math' as math;

/// Spectrum measurements consumed by the pure Fourier Music mapping layer.
///
/// Every scalar is expected to be normalized to `[0, 1]`, except
/// [orientation], which is an axial angle in `[0, pi)`. The mapper still
/// validates and clamps values so malformed analysis cannot reach audio code.
class FourierMusicSpectrumFrame {
  const FourierMusicSpectrumFrame({
    required this.lowPowerRatio,
    required this.midPowerRatio,
    required this.highPowerRatio,
    required this.centroid,
    required this.entropy,
    required this.flatness,
    required this.orientation,
    required this.anisotropy,
    required this.spectralFlux,
    this.isValid = true,
  });

  final double lowPowerRatio;
  final double midPowerRatio;
  final double highPowerRatio;
  final double centroid;
  final double entropy;
  final double flatness;
  final double orientation;
  final double anisotropy;
  final double spectralFlux;
  final bool isValid;
}

/// Bounded arrangement controls derived from one spectrum frame.
class FourierMusicFeatures {
  const FourierMusicFeatures({
    required this.bassWeight,
    required this.padOpenness,
    required this.highTexture,
    required this.leadRegister,
    required this.rhythmicComplexity,
    required this.stereoBias,
    required this.transitionStrength,
    required this.orientation,
    required this.anisotropy,
    required this.isSilent,
  });

  const FourierMusicFeatures.silence()
      : bassWeight = 0,
        padOpenness = 0,
        highTexture = 0,
        leadRegister = 0,
        rhythmicComplexity = 0,
        stereoBias = 0,
        transitionStrength = 0,
        orientation = 0,
        anisotropy = 0,
        isSilent = true;

  final double bassWeight;
  final double padOpenness;
  final double highTexture;
  final double leadRegister;
  final double rhythmicComplexity;
  final double stereoBias;
  final double transitionStrength;
  final double orientation;
  final double anisotropy;
  final bool isSilent;

  List<double> get normalizedValues => <double>[
        bassWeight,
        padOpenness,
        highTexture,
        leadRegister,
        rhythmicComplexity,
        transitionStrength,
        anisotropy,
      ];
}

/// Pure artistic mapping from measured spectrum features to arrangement data.
class FourierMusicFeatureMapper {
  const FourierMusicFeatureMapper();

  FourierMusicFeatures map(FourierMusicSpectrumFrame frame) {
    final values = <double>[
      frame.lowPowerRatio,
      frame.midPowerRatio,
      frame.highPowerRatio,
      frame.centroid,
      frame.entropy,
      frame.flatness,
      frame.orientation,
      frame.anisotropy,
      frame.spectralFlux,
    ];
    if (!frame.isValid || values.any((value) => !value.isFinite)) {
      return const FourierMusicFeatures.silence();
    }

    final low = _unit(frame.lowPowerRatio);
    final mid = _unit(frame.midPowerRatio);
    final high = _unit(frame.highPowerRatio);
    final power = low + mid + high;
    if (power <= 0) return const FourierMusicFeatures.silence();

    final anisotropy = _unit(frame.anisotropy);
    final orientation = _axialAngle(frame.orientation);
    return FourierMusicFeatures(
      bassWeight: low / power,
      padOpenness: mid / power,
      highTexture: high / power,
      leadRegister: _unit(frame.centroid),
      rhythmicComplexity: (_unit(frame.entropy) + _unit(frame.flatness)) / 2,
      stereoBias: anisotropy * math.cos(2 * orientation),
      transitionStrength: _unit(frame.spectralFlux),
      orientation: orientation,
      anisotropy: anisotropy,
      isSilent: false,
    );
  }
}

/// Stateful three-sample glitch median followed by an EWMA.
///
/// Orientation is filtered as the doubled-angle complex moment, because the
/// measured direction is an axis modulo `pi`, not an arrow.
class FourierMusicFeatureSmoother {
  FourierMusicFeatureSmoother({this.ewmaAlpha = 0.35})
      : assert(ewmaAlpha > 0 && ewmaAlpha <= 1);

  final double ewmaAlpha;
  final Map<String, List<double>> _history = <String, List<double>>{};
  final Map<String, double> _state = <String, double>{};

  FourierMusicFeatures update(FourierMusicFeatures input) {
    if (input.isSilent) {
      reset();
      return const FourierMusicFeatures.silence();
    }

    final bass = _smooth('bass', input.bassWeight);
    final pad = _smooth('pad', input.padOpenness);
    final high = _smooth('high', input.highTexture);
    final register = _smooth('register', input.leadRegister);
    final complexity = _smooth('complexity', input.rhythmicComplexity);
    final transition = _smooth('transition', input.transitionStrength);
    final anisotropy = _smooth('anisotropy', input.anisotropy);
    final orientationX = _smooth(
      'orientationX',
      math.cos(2 * input.orientation),
    );
    final orientationY = _smooth(
      'orientationY',
      math.sin(2 * input.orientation),
    );
    final orientation = _axialAngle(
      math.atan2(orientationY, orientationX) / 2,
    );

    return FourierMusicFeatures(
      bassWeight: _unit(bass),
      padOpenness: _unit(pad),
      highTexture: _unit(high),
      leadRegister: _unit(register),
      rhythmicComplexity: _unit(complexity),
      stereoBias: anisotropy * math.cos(2 * orientation),
      transitionStrength: _unit(transition),
      orientation: orientation,
      anisotropy: _unit(anisotropy),
      isSilent: false,
    );
  }

  void reset() {
    _history.clear();
    _state.clear();
  }

  double _smooth(String key, double value) {
    final samples = _history.putIfAbsent(key, () => <double>[]);
    samples.add(value);
    if (samples.length > 3) samples.removeAt(0);
    final filtered = _median(samples);
    final previous = _state[key];
    final next = previous == null
        ? filtered
        : previous + ewmaAlpha * (filtered - previous);
    _state[key] = next;
    return next;
  }
}

enum FourierMusicRhythmDensity { sparse, steady, busy }

enum FourierMusicRegisterBand { low, middle, high }

class FourierMusicDecisions {
  const FourierMusicDecisions({
    required this.rhythmDensity,
    required this.registerBand,
  });

  final FourierMusicRhythmDensity rhythmDensity;
  final FourierMusicRegisterBand registerBand;
}

/// Quantizes slow musical choices with hysteresis and bar-safe commits.
class FourierMusicDecisionController {
  FourierMusicDecisionController({this.hysteresis = 0.05})
      : assert(hysteresis >= 0 && hysteresis < 0.3);

  final double hysteresis;
  int _rhythmIndex = 1;
  int _registerIndex = 1;

  void reset() {
    _rhythmIndex = 1;
    _registerIndex = 1;
  }

  FourierMusicDecisions update(
    FourierMusicFeatures features, {
    required bool isBarBoundary,
  }) {
    if (isBarBoundary && !features.isSilent) {
      _rhythmIndex = _bandWithHysteresis(
        features.rhythmicComplexity,
        _rhythmIndex,
      );
      _registerIndex = _bandWithHysteresis(
        features.leadRegister,
        _registerIndex,
      );
    }
    return FourierMusicDecisions(
      rhythmDensity: FourierMusicRhythmDensity.values[_rhythmIndex],
      registerBand: FourierMusicRegisterBand.values[_registerIndex],
    );
  }

  int _bandWithHysteresis(double value, int current) {
    switch (current) {
      case 0:
        return value > 0.3 + hysteresis ? 1 : 0;
      case 1:
        if (value < 0.3 - hysteresis) return 0;
        if (value > 0.7 + hysteresis) return 2;
        return 1;
      case 2:
        return value < 0.7 - hysteresis ? 1 : 2;
    }
    throw StateError('Unknown Fourier Music band $current');
  }
}

double _median(List<double> values) {
  final sorted = List<double>.of(values)..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return (sorted[middle - 1] + sorted[middle]) / 2;
}

double _unit(double value) => value.clamp(0.0, 1.0).toDouble();

double _axialAngle(double angle) {
  final wrapped = angle % math.pi;
  return wrapped < 0 ? wrapped + math.pi : wrapped;
}
