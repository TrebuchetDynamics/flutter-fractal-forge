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
class F1036MartinHopalongCrystalMetadata {
  static const instance = F1036MartinHopalongCrystalMetadata._();
  const F1036MartinHopalongCrystalMetadata._();

  String get id => 'f1036_martin_hopalong_crystal';
  String get name => 'Martin Hopalong Crystal';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=11.0 b=0.05 c=0.0',
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
