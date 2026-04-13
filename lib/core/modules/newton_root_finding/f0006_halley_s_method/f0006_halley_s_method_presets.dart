// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0006HalleySMethodPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0006HalleySMethodPreset({required this.id, required this.name, required this.params});
}

class F0006HalleySMethodPresets {
  static const F0006HalleySMethodPreset cubic = F0006HalleySMethodPreset(
    id: 'cubic',
    name: 'Cubic (d=3)',
    params: {
      'power': 3.0,
    },
  );
  static const F0006HalleySMethodPreset quartic = F0006HalleySMethodPreset(
    id: 'quartic',
    name: 'Quartic (d=4)',
    params: {
      'power': 4.0,
    },
  );
  static const F0006HalleySMethodPreset quintic = F0006HalleySMethodPreset(
    id: 'quintic',
    name: 'Quintic (d=5)',
    params: {
      'power': 5.0,
    },
  );

  static const List<F0006HalleySMethodPreset> all = [
    cubic,
    quartic,
    quintic,
  ];
}
