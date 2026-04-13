// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0476TripleAntennaPointPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0476TripleAntennaPointPreset({required this.id, required this.name, required this.params});
}

class F0476TripleAntennaPointPresets {
  static const F0476TripleAntennaPointPreset namedView = F0476TripleAntennaPointPreset(
    id: 'named_view',
    name: 'Triple Antenna Point view',
    params: {
      'center_re': -0.15,
      'center_im': 1.033,
      'zoom': 300.0,
    },
  );

  static const List<F0476TripleAntennaPointPreset> all = [
    namedView,
  ];
}
