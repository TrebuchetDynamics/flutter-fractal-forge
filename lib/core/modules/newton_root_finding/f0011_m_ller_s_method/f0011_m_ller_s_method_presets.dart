// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0011MLlerSMethodPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0011MLlerSMethodPreset({required this.id, required this.name, required this.params});
}

class F0011MLlerSMethodPresets {
  static const F0011MLlerSMethodPreset cubic = F0011MLlerSMethodPreset(
    id: 'cubic',
    name: 'Cubic (d=3)',
    params: {
      'power': 3.0,
    },
  );
  static const F0011MLlerSMethodPreset quartic = F0011MLlerSMethodPreset(
    id: 'quartic',
    name: 'Quartic (d=4)',
    params: {
      'power': 4.0,
    },
  );

  static const List<F0011MLlerSMethodPreset> all = [
    cubic,
    quartic,
  ];
}
