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
class F0759FordCirclesApollonianMetadata {
  static const instance = F0759FordCirclesApollonianMetadata._();
  const F0759FordCirclesApollonianMetadata._();

  String get id => 'f0759_ford_circles_apollonian';
  String get name => 'Ford Circles Apollonian';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Ford circles',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. R. Ford',
      title: 'Fractions',
      year: 1938,
      url: 'https://doi.org/10.2307/2302799',
    ),
  ];
}
