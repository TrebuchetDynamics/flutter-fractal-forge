// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0013PolynomiographyBasicFamilyIterationPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0013PolynomiographyBasicFamilyIterationPreset({required this.id, required this.name, required this.params});
}

class F0013PolynomiographyBasicFamilyIterationPresets {
  static const F0013PolynomiographyBasicFamilyIterationPreset m2Cubic = F0013PolynomiographyBasicFamilyIterationPreset(
    id: 'm2_cubic',
    name: 'B2 cubic (m=2, d=3)',
    params: {
      'order': 2.0,
      'power': 3.0,
    },
  );
  static const F0013PolynomiographyBasicFamilyIterationPreset m3Cubic = F0013PolynomiographyBasicFamilyIterationPreset(
    id: 'm3_cubic',
    name: 'B3 cubic (m=3, d=3)',
    params: {
      'order': 3.0,
      'power': 3.0,
    },
  );
  static const F0013PolynomiographyBasicFamilyIterationPreset m1IsNewton = F0013PolynomiographyBasicFamilyIterationPreset(
    id: 'm1_is_newton',
    name: 'B1 (reduces to Newton)',
    params: {
      'order': 1.0,
      'power': 3.0,
    },
  );

  static const List<F0013PolynomiographyBasicFamilyIterationPreset> all = [
    m2Cubic,
    m3Cubic,
    m1IsNewton,
  ];
}
