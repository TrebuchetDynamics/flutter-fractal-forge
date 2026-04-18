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
class F0847QuadraticKochIslandTypeBMetadata {
  static const instance = F0847QuadraticKochIslandTypeBMetadata._();
  const F0847QuadraticKochIslandTypeBMetadata._();

  String get id => 'f0847_quadratic_koch_island_type_b';
  String get name => 'Quadratic Koch Island (Type B)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Quadratic Koch B',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
