// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0007SchrDerSMethodPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0007SchrDerSMethodPreset({required this.id, required this.name, required this.params});
}

class F0007SchrDerSMethodPresets {
  static const F0007SchrDerSMethodPreset classicOrder2 = F0007SchrDerSMethodPreset(
    id: 'classic_order_2',
    name: 'Order k=2 (classic Schröder)',
    params: {
      'order': 2.0,
      'power': 3.0,
    },
  );
  static const F0007SchrDerSMethodPreset order3 = F0007SchrDerSMethodPreset(
    id: 'order_3',
    name: 'Order k=3',
    params: {
      'order': 3.0,
      'power': 3.0,
    },
  );
  static const F0007SchrDerSMethodPreset order1IsNewton = F0007SchrDerSMethodPreset(
    id: 'order_1_is_newton',
    name: 'Order k=1 (reduces to Newton)',
    params: {
      'order': 1.0,
      'power': 3.0,
    },
  );

  static const List<F0007SchrDerSMethodPreset> all = [
    classicOrder2,
    order3,
    order1IsNewton,
  ];
}
