// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0480PickoverStalksPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0480PickoverStalksPreset({required this.id, required this.name, required this.params});
}

class F0480PickoverStalksPresets {
  static const F0480PickoverStalksPreset namedView = F0480PickoverStalksPreset(
    id: 'named_view',
    name: 'Pickover Stalks view',
    params: {
      'center_re': -0.75,
      'center_im': 0.095,
      'zoom': 100.0,
    },
  );

  static const List<F0480PickoverStalksPreset> all = [
    namedView,
  ];
}
