// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0477HeartZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0477HeartZoomPreset({required this.id, required this.name, required this.params});
}

class F0477HeartZoomPresets {
  static const F0477HeartZoomPreset namedView = F0477HeartZoomPreset(
    id: 'named_view',
    name: 'Heart Zoom view',
    params: {
      'center_re': 0.268,
      'center_im': 0.004,
      'zoom': 500.0,
    },
  );

  static const List<F0477HeartZoomPreset> all = [
    namedView,
  ];
}
