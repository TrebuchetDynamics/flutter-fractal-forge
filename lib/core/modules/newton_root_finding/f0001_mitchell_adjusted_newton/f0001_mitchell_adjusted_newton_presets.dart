// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0001MitchellAdjustedNewtonPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0001MitchellAdjustedNewtonPreset({required this.id, required this.name, required this.params});
}

class F0001MitchellAdjustedNewtonPresets {
  static const F0001MitchellAdjustedNewtonPreset classic = F0001MitchellAdjustedNewtonPreset(
    id: 'classic',
    name: 'Classic (alpha=1, standard Newton)',
    params: {
      'alpha_re': 1.0,
      'alpha_im': 0.0,
      'power': 4.0,
    },
  );
  static const F0001MitchellAdjustedNewtonPreset curved = F0001MitchellAdjustedNewtonPreset(
    id: 'curved',
    name: 'Curved (alpha=1.3+0.5i)',
    params: {
      'alpha_re': 1.3,
      'alpha_im': 0.5,
      'power': 4.0,
    },
  );
  static const F0001MitchellAdjustedNewtonPreset nonConverging = F0001MitchellAdjustedNewtonPreset(
    id: 'non_converging',
    name: 'Non-converging (alpha=1.470+0.899i)',
    params: {
      'alpha_re': 1.47,
      'alpha_im': 0.899,
      'power': 4.0,
    },
  );
  static const F0001MitchellAdjustedNewtonPreset threeArmSpiral = F0001MitchellAdjustedNewtonPreset(
    id: 'three_arm_spiral',
    name: 'Three-armed Spiral (alpha=1.5+0.9i)',
    params: {
      'alpha_re': 1.5,
      'alpha_im': 0.9,
      'power': 4.0,
    },
  );

  static const List<F0001MitchellAdjustedNewtonPreset> all = [
    classic,
    curved,
    nonConverging,
    threeArmSpiral,
  ];
}
