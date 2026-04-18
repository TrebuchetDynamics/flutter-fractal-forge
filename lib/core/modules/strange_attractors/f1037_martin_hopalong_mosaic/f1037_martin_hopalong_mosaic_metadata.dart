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
class F1037MartinHopalongMosaicMetadata {
  static const instance = F1037MartinHopalongMosaicMetadata._();
  const F1037MartinHopalongMosaicMetadata._();

  String get id => 'f1037_martin_hopalong_mosaic';
  String get name => 'Martin Hopalong Mosaic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=7.16878197 b=8.43659746 c=2.55983412',
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
