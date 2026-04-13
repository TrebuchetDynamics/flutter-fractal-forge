// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0428ElephantTrunkZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0428ElephantTrunkZoomPreset({required this.id, required this.name, required this.params});
}

class F0428ElephantTrunkZoomPresets {
  static const F0428ElephantTrunkZoomPreset namedView = F0428ElephantTrunkZoomPreset(
    id: 'named_view',
    name: 'Elephant Trunk Zoom view',
    params: {
      'center_re': 0.2897,
      'center_im': 0.0128,
      'zoom': 100.0,
    },
  );

  static const List<F0428ElephantTrunkZoomPreset> all = [
    namedView,
  ];
}
