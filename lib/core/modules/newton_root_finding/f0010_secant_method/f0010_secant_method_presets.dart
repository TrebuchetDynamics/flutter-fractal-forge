// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0010SecantMethodPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0010SecantMethodPreset({required this.id, required this.name, required this.params});
}

class F0010SecantMethodPresets {
  static const F0010SecantMethodPreset cubic = F0010SecantMethodPreset(
    id: 'cubic',
    name: 'Cubic (d=3)',
    params: {
      'power': 3.0,
    },
  );
  static const F0010SecantMethodPreset quartic = F0010SecantMethodPreset(
    id: 'quartic',
    name: 'Quartic (d=4)',
    params: {
      'power': 4.0,
    },
  );

  static const List<F0010SecantMethodPreset> all = [
    cubic,
    quartic,
  ];
}
