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
class F1038MartinHopalongVortexMetadata {
  static const instance = F1038MartinHopalongVortexMetadata._();
  const F1038MartinHopalongVortexMetadata._();

  String get id => 'f1038_martin_hopalong_vortex';
  String get name => 'Martin Hopalong Vortex';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=-3.14 b=-1.41 c=-2.71',
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
