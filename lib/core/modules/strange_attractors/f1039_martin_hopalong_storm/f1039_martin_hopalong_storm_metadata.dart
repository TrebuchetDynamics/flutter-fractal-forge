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
class F1039MartinHopalongStormMetadata {
  static const instance = F1039MartinHopalongStormMetadata._();
  const F1039MartinHopalongStormMetadata._();

  String get id => 'f1039_martin_hopalong_storm';
  String get name => 'Martin Hopalong Storm';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=9.7 b=1.999 c=50.0',
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
