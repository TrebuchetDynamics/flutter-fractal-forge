// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0008ChebyshevSMethodPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0008ChebyshevSMethodPreset({required this.id, required this.name, required this.params});
}

class F0008ChebyshevSMethodPresets {
  static const F0008ChebyshevSMethodPreset cubic = F0008ChebyshevSMethodPreset(
    id: 'cubic',
    name: 'Cubic (d=3)',
    params: {
      'power': 3.0,
    },
  );
  static const F0008ChebyshevSMethodPreset quartic = F0008ChebyshevSMethodPreset(
    id: 'quartic',
    name: 'Quartic (d=4)',
    params: {
      'power': 4.0,
    },
  );

  static const List<F0008ChebyshevSMethodPreset> all = [
    cubic,
    quartic,
  ];
}
