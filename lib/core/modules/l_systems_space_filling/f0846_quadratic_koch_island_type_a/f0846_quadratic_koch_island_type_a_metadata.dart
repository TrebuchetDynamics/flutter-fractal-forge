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
class F0846QuadraticKochIslandTypeAMetadata {
  static const instance = F0846QuadraticKochIslandTypeAMetadata._();
  const F0846QuadraticKochIslandTypeAMetadata._();

  String get id => 'f0846_quadratic_koch_island_type_a';
  String get name => 'Quadratic Koch Island (Type A)';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Quadratic Koch A',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}
