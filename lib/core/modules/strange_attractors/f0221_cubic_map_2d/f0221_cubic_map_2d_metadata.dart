// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class F0221CubicMap2dMetadata {
  static const instance = F0221CubicMap2dMetadata._();
  const F0221CubicMap2dMetadata._();

  String get id => 'f0221_cubic_map_2d';
  String get name => 'Cubic Map 2D';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Strange Attractors: Creating Patterns in Chaos',
      year: 1993,
      url: 'https://sprott.physics.wisc.edu/fractals.htm',
    ),
  ];
}
