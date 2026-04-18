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
class F1035MartinHopalongSpiderMetadata {
  static const instance = F1035MartinHopalongSpiderMetadata._();
  const F1035MartinHopalongSpiderMetadata._();

  String get id => 'f1035_martin_hopalong_spider';
  String get name => 'Martin Hopalong Spider';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=0.41 b=1.05 c=0.02',
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
