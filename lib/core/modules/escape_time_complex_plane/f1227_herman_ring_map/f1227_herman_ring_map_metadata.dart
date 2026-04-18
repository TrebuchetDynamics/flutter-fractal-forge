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
class F1227HermanRingMapMetadata {
  static const instance = F1227HermanRingMapMetadata._();
  const F1227HermanRingMapMetadata._();

  String get id => 'f1227_herman_ring_map';
  String get name => 'Herman Ring Map';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Herman ring',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Complex_dynamics',
    ),
  ];
}
