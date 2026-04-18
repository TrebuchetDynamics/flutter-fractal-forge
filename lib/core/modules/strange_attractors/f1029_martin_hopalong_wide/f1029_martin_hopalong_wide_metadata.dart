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
class F1029MartinHopalongWideMetadata {
  static const instance = F1029MartinHopalongWideMetadata._();
  const F1029MartinHopalongWideMetadata._();

  String get id => 'f1029_martin_hopalong_wide';
  String get name => 'Martin Hopalong Wide';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Martin a=0.4 b=1.0 c=0.0',
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
