// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0012NovaFractalVariant {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0012NovaFractalVariant({required this.id, required this.name, required this.params});
}

class F0012NovaFractalVariants {
  static const F0012NovaFractalVariant quarticNova = F0012NovaFractalVariant(
    id: 'quartic_nova',
    name: 'Quartic Nova (d=4)',
    params: {
      'power': 4.0,
    },
  );

  static const List<F0012NovaFractalVariant> all = [
    quarticNova,
  ];
}
