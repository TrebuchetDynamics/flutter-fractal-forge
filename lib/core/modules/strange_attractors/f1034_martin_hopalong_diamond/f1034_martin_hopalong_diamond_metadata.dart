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
class F1034MartinHopalongDiamondMetadata {
  static const instance = F1034MartinHopalongDiamondMetadata._();
  const F1034MartinHopalongDiamondMetadata._();

  String get id => 'f1034_martin_hopalong_diamond';
  String get name => 'Martin Hopalong Diamond';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=-200 b=0.1 c=-80',
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
