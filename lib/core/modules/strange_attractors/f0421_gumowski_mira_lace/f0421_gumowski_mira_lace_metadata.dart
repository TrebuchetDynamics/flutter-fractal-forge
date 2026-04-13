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
class F0421GumowskiMiraLaceMetadata {
  static const instance = F0421GumowskiMiraLaceMetadata._();
  const F0421GumowskiMiraLaceMetadata._();

  String get id => 'f0421_gumowski_mira_lace';
  String get name => 'Gumowski-Mira Lace';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Gumowski-Mira a=-0.45 b=0.0',
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
