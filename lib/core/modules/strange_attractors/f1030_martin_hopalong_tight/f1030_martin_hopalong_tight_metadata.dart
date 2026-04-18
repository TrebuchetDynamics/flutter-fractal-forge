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
class F1030MartinHopalongTightMetadata {
  static const instance = F1030MartinHopalongTightMetadata._();
  const F1030MartinHopalongTightMetadata._();

  String get id => 'f1030_martin_hopalong_tight';
  String get name => 'Martin Hopalong Tight';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=5.0 b=1.5 c=10.0',
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
