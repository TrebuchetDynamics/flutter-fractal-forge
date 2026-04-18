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
class F0815QuadraticMapC20Metadata {
  static const instance = F0815QuadraticMapC20Metadata._();
  const F0815QuadraticMapC20Metadata._();

  String get id => 'f0815_quadratic_map_c_2_0';
  String get name => 'Quadratic Map c=-2.0';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. V. Jakobson',
      title: 'Absolutely continuous invariant measures for one-parameter families of one-dimensional maps',
      year: 1981,
      url: 'https://en.wikipedia.org/wiki/Quadratic_map',
    ),
  ];
}
