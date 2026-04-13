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
class F0420GumowskiMiraPropellerMetadata {
  static const instance = F0420GumowskiMiraPropellerMetadata._();
  const F0420GumowskiMiraPropellerMetadata._();

  String get id => 'f0420_gumowski_mira_propeller';
  String get name => 'Gumowski-Mira Propeller';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Gumowski-Mira a=0.2 b=0.9',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'I. Gumowski, C. Mira',
      title: 'Recurrences and Discrete Dynamic Systems',
      year: 1980,
      url: 'https://doi.org/10.1007/BFb0089135',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Gumowski-Mira attractors',
      year: 2004,
      url: 'http://paulbourke.net/fractals/gumowski/',
    ),
  ];
}
