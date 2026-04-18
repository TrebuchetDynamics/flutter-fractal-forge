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
class F0814QuadraticMapC14Metadata {
  static const instance = F0814QuadraticMapC14Metadata._();
  const F0814QuadraticMapC14Metadata._();

  String get id => 'f0814_quadratic_map_c_1_4';
  String get name => 'Quadratic Map c=-1.4';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Local connectivity of Julia sets',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Quadratic_map',
    ),
  ];
}
