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
class F0353CliffordRoseMetadata {
  static const instance = F0353CliffordRoseMetadata._();
  const F0353CliffordRoseMetadata._();

  String get id => 'f0353_clifford_rose';
  String get name => 'Clifford Rose';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Clifford a=1.5 b=1.5 c=0.5 d=0.5',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Clifford A. Pickover',
      title: 'Chaos in Wonderland: Visual Adventures in a Fractal World',
      year: 1994,
      url: 'https://en.wikipedia.org/wiki/Clifford_A._Pickover',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Clifford attractors',
      year: 2006,
      url: 'http://paulbourke.net/fractals/clifford/',
    ),
  ];
}
