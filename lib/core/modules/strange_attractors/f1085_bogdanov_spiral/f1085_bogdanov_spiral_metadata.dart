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
class F1085BogdanovSpiralMetadata {
  static const instance = F1085BogdanovSpiralMetadata._();
  const F1085BogdanovSpiralMetadata._();

  String get id => 'f1085_bogdanov_spiral';
  String get name => 'Bogdanov Spiral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Bogdanov k=0.8',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. I. Bogdanov',
      title: 'Bifurcations of a limit cycle for a family of vector fields on the plane',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Bogdanov_map',
    ),
  ];
}
