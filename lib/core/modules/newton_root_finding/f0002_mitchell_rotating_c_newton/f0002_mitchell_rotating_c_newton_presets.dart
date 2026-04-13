// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0002MitchellRotatingCNewtonPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0002MitchellRotatingCNewtonPreset({required this.id, required this.name, required this.params});
}

class F0002MitchellRotatingCNewtonPresets {
  static const F0002MitchellRotatingCNewtonPreset coherent = F0002MitchellRotatingCNewtonPreset(
    id: 'coherent',
    name: 'Coherent (theta=85 deg)',
    params: {
      'theta_deg': 85.0,
      'power': 3.0,
    },
  );
  static const F0002MitchellRotatingCNewtonPreset fineDetail = F0002MitchellRotatingCNewtonPreset(
    id: 'fine_detail',
    name: 'Fine Detail (theta=87 deg)',
    params: {
      'theta_deg': 87.0,
      'power': 3.0,
    },
  );
  static const F0002MitchellRotatingCNewtonPreset nearNoise = F0002MitchellRotatingCNewtonPreset(
    id: 'near_noise',
    name: 'Near-noise (theta=89 deg)',
    params: {
      'theta_deg': 89.0,
      'power': 3.0,
    },
  );

  static const List<F0002MitchellRotatingCNewtonPreset> all = [
    coherent,
    fineDetail,
    nearNoise,
  ];
}
