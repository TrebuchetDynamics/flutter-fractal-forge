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
class F1031MartinHopalongSpiralMetadata {
  static const instance = F1031MartinHopalongSpiralMetadata._();
  const F1031MartinHopalongSpiralMetadata._();

  String get id => 'f1031_martin_hopalong_spiral';
  String get name => 'Martin Hopalong Spiral';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=2.0 b=1.0 c=5.0',
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
