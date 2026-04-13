// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0005MitchellMatrixNewtonSandStormPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0005MitchellMatrixNewtonSandStormPreset({required this.id, required this.name, required this.params});
}

class F0005MitchellMatrixNewtonSandStormPresets {
  static const F0005MitchellMatrixNewtonSandStormPreset sandStorm = F0005MitchellMatrixNewtonSandStormPreset(
    id: 'sand_storm',
    name: 'Sand Storm (identity matrix)',
    params: {
      'afx': 1.0,
      'afy': 0.0,
      'agx': 0.0,
      'agy': 1.0,
    },
  );
  static const F0005MitchellMatrixNewtonSandStormPreset asymmetric = F0005MitchellMatrixNewtonSandStormPreset(
    id: 'asymmetric',
    name: 'Asymmetric (afy=0.3)',
    params: {
      'afx': 1.0,
      'afy': 0.3,
      'agx': 0.0,
      'agy': 1.0,
    },
  );
  static const F0005MitchellMatrixNewtonSandStormPreset coupled = F0005MitchellMatrixNewtonSandStormPreset(
    id: 'coupled',
    name: 'Coupled (off-diagonal)',
    params: {
      'afx': 0.8,
      'afy': 0.4,
      'agx': 0.4,
      'agy': 0.8,
    },
  );

  static const List<F0005MitchellMatrixNewtonSandStormPreset> all = [
    sandStorm,
    asymmetric,
    coupled,
  ];
}
