// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0459NorthAntennaPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0459NorthAntennaPreset({required this.id, required this.name, required this.params});
}

class F0459NorthAntennaPresets {
  static const F0459NorthAntennaPreset namedView = F0459NorthAntennaPreset(
    id: 'named_view',
    name: 'North Antenna view',
    params: {
      'center_re': -1.1,
      'center_im': 0.0,
      'zoom': 5.0,
    },
  );

  static const List<F0459NorthAntennaPreset> all = [
    namedView,
  ];
}
