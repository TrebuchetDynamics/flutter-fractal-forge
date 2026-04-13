// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0001MitchellAdjustedNewtonVariant {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0001MitchellAdjustedNewtonVariant({required this.id, required this.name, required this.params});
}

class F0001MitchellAdjustedNewtonVariants {
  static const F0001MitchellAdjustedNewtonVariant cubic = F0001MitchellAdjustedNewtonVariant(
    id: 'cubic',
    name: 'Cubic variant (d=3)',
    params: {
      'power': 3.0,
    },
  );
  static const F0001MitchellAdjustedNewtonVariant quintic = F0001MitchellAdjustedNewtonVariant(
    id: 'quintic',
    name: 'Quintic variant (d=5)',
    params: {
      'power': 5.0,
    },
  );

  static const List<F0001MitchellAdjustedNewtonVariant> all = [
    cubic,
    quintic,
  ];
}
