// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0468SnowflakeRegionPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0468SnowflakeRegionPreset({required this.id, required this.name, required this.params});
}

class F0468SnowflakeRegionPresets {
  static const F0468SnowflakeRegionPreset namedView = F0468SnowflakeRegionPreset(
    id: 'named_view',
    name: 'Snowflake Region view',
    params: {
      'center_re': -1.25066,
      'center_im': 0.02012,
      'zoom': 1000.0,
    },
  );

  static const List<F0468SnowflakeRegionPreset> all = [
    namedView,
  ];
}
