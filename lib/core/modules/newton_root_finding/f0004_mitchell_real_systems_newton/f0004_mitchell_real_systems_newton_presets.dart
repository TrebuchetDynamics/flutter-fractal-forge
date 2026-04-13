// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0004MitchellRealSystemsNewtonPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0004MitchellRealSystemsNewtonPreset({required this.id, required this.name, required this.params});
}

class F0004MitchellRealSystemsNewtonPresets {
  static const F0004MitchellRealSystemsNewtonPreset noMult = F0004MitchellRealSystemsNewtonPreset(
    id: 'no_mult',
    name: 'No multiplier (independent components)',
    params: {
      'k_re': 1.0,
      'k_im': 0.0,
    },
  );
  static const F0004MitchellRealSystemsNewtonPreset classic2MinusI = F0004MitchellRealSystemsNewtonPreset(
    id: 'classic_2_minus_i',
    name: 'Classic k = 2-i',
    params: {
      'k_re': 2.0,
      'k_im': -1.0,
    },
  );
  static const F0004MitchellRealSystemsNewtonPreset reciprocal = F0004MitchellRealSystemsNewtonPreset(
    id: 'reciprocal',
    name: 'Reciprocal mode (k = i)',
    params: {
      'k_re': 0.0,
      'k_im': 1.0,
    },
  );

  static const List<F0004MitchellRealSystemsNewtonPreset> all = [
    noMult,
    classic2MinusI,
    reciprocal,
  ];
}
