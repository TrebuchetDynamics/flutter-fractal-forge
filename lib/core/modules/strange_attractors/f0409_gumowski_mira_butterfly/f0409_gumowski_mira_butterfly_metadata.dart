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
class F0409GumowskiMiraButterflyMetadata {
  static const instance = F0409GumowskiMiraButterflyMetadata._();
  const F0409GumowskiMiraButterflyMetadata._();

  String get id => 'f0409_gumowski_mira_butterfly';
  String get name => 'Gumowski-Mira Butterfly';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Gumowski-Mira a=0.008 b=0.05',
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
