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
class F1040MartinHopalongRosetteMetadata {
  static const instance = F1040MartinHopalongRosetteMetadata._();
  const F1040MartinHopalongRosetteMetadata._();

  String get id => 'f1040_martin_hopalong_rosette';
  String get name => 'Martin Hopalong Rosette';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=1.4 b=0.13 c=6.9',
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
