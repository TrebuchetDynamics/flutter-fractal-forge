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
class F1028MartinHopalongClassicMetadata {
  static const instance = F1028MartinHopalongClassicMetadata._();
  const F1028MartinHopalongClassicMetadata._();

  String get id => 'f1028_martin_hopalong_classic';
  String get name => 'Martin Hopalong (Classic)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=1.0 b=2.0 c=3.0',
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
