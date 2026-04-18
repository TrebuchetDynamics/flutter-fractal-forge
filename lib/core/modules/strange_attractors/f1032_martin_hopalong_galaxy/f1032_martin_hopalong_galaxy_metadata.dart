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
class F1032MartinHopalongGalaxyMetadata {
  static const instance = F1032MartinHopalongGalaxyMetadata._();
  const F1032MartinHopalongGalaxyMetadata._();

  String get id => 'f1032_martin_hopalong_galaxy';
  String get name => 'Martin Hopalong Galaxy';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=-2.0 b=-3.0 c=-10.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Martin / C. Pickover',
      title: 'Hopalong attractor',
      year: 1986,
      url: 'http://paulbourke.net/fractals/martin/',
    ),
  ];
}
