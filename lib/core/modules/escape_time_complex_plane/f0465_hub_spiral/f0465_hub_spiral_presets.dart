// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0465HubSpiralPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0465HubSpiralPreset({required this.id, required this.name, required this.params});
}

class F0465HubSpiralPresets {
  static const F0465HubSpiralPreset namedView = F0465HubSpiralPreset(
    id: 'named_view',
    name: 'Hub Spiral view',
    params: {
      'center_re': -1.2556,
      'center_im': 0.37999,
      'zoom': 5000.0,
    },
  );

  static const List<F0465HubSpiralPreset> all = [
    namedView,
  ];
}
